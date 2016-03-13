require 'net/http'

module Curator
  class CoreNLPClient
    def initialize(host)
      params = URI.encode('properties={"annotators": "lemma,tokenize,ssplit,depparse"}')

      @uri = URI(host + "/?" + params)
      @http_client = Net::HTTP.new(@uri.host, @uri.port)
    end

    def request_parse(text)
      req = Net::HTTP::Post.new(@uri)
      req.body = text
      JSON.parse(@http_client.request(req).body)['sentences'].map do |sentence|
        [sentence['tokens'], sentence['collapsed-ccprocessed-dependencies']]
      end
    end
  end

  def self.sorted_dup_hash(array)
    Hash[*array.inject(Hash.new(0)) { |h,e| h[e] += 1; h }.
    select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }.
    sort_by {|_,v| v}.reverse.flatten(1)]
  end

  def self.select_best(points)
    points = reparse_points(points.uniq { |p| p["String"] })
    #permitted(points).min_by { |p| p["String"].length }
    points = permitted(points)

    group_bigrams = []
    points.each do |p|
      group_bigrams += bigrams(p["String"])
    end
    group_bigrams = sorted_dup_hash(group_bigrams)
    points = points.sort_by do |p|
      clean = p["String"].downcase.gsub(/[^\s\w']/, "").gsub(/\s+/, " ").strip
      score = 0
      group_bigrams.each do |k, v|
        score += v if clean.include? k
      end
      p["Score"] = score.to_f / clean.split(" ").size
    end.last
  end

  def self.select_best_question(points)
    points.reject! do |p|
      p["String"].strip[-1] != "?"
    end
    points.sort_by {|x|x["String"].length}.first
  end

  def self.bigrams(string)
    words = string.downcase.gsub(/[^\s\w']/, "").split(/\s+/)
    words.each_with_index.to_a[0..-2].map do |e, i|
      [e, words[i+1]].join(" ")
    end
  end

  def self.reparse_points(points)
    cnc = CoreNLPClient.new("http://local.docker:9000")
    points.map do |point|
      parse = cnc.request_parse(clean_string(point["String"])).first
      point["Relations"], point["Lemmas"] = relations_and_lemmas_from_parse(parse)
      point
    end
  end

  def self.permitted(points)
    points.reject do |point|
      !point["String"].length.between?(15, 100) ||
      #point["String"].match(/^(if|and|but|or|just|after|before|their|his|her|why)/i) ||
      point["String"].match(/this|And/) ||
      point["String"].match(/^\w+ ?, /) ||
      point["String"].match(/(\s*,){2}/) ||
      point["String"].match(/([A-Z]+ ){2,}/) ||
      point["String"].scan(/[a-z]+[0-9A-Z]/).any? ||
      point["String"].scan(/[LR]RB|[LR]SB/).size.odd? ||
      point["Relations"].count { |r| r.match(/dep|acl|csubj|ccomp/) } > 0 ||
      point["Relations"].count { |r| r.match(/advcl/) } > 1 ||
      point["Relations"].count { |r| r.match(/conj|nmod/) } > 2 ||
      contains_case_change(point) ||
      contains_bad_it(point) ||
      boring_words(point, 2)
    end
  end

  def self.clean_string(string, question=false)
    string = string.strip
      .gsub(/^\W+/, "")
      .gsub(/ ?- ?\.?$/, "")
      .gsub(/[\s;\.,]+$/, "")
      .gsub(/\s+(n?[,'\.])/, '\1')
      .gsub("-LRB-", "(").gsub("-RRB-", ")")
      .gsub("( ", "(").gsub(" )", ")")
      .gsub("-LSB-", "[").gsub("-RSB-", "]")
      .gsub("[ ", "[").gsub(" ]", "]").strip
      .gsub("` ", "'")
      .gsub(/(\W+\w{0,1})$/, "")
      .gsub("does not", "doesn't").gsub("can not", "can't").gsub("do not", "don't")
      .gsub(" i ", " I ")
      .gsub(/[^A-Za-z\)\}\]]+$/, "")
    unless question
      string.gsub!(/^(then|than|so|to|when|what|that|even if|if|of|even|about|because)\s/i, "")
    end
    string = "#{string[0].upcase}#{string[1..-1]}" rescue binding.pry
    string.gsub!(/[;.]+/, "")
    string.gsub!(/ [:\-]$/, "")
    string.gsub!(" ,", "")
    string = string.strip
    if question
      string += "?" if string.strip[-1] != "?"
    else
      string += "." if string.strip[-1] != "."
    end
    string
  end

  def self.relations_and_lemmas_from_parse(parse)
    relations = parse.last.group_by { |r| r["dependent"] }
      .map { |k, v| [k-1, v.map { |r| r["dep"] }] }
      .sort_by { |index, _| index }
      .map(&:last).map { |r| r.join("|") }
    return relations, parse.first.map { |t| t["lemma"] + ":" + t["originalText"] + ":" + t["pos"] }
  end

  def self.contains_case_change(point)
    return false unless point["String"].match(/\s[A-Z]/)
    point["Lemmas"].count do |e|
      next unless e.match(/\w/) && point["Lemmas"].index(e) > 0
      e = e.split(":")
      e[1].match(/^[A-Z]/) && !e[2].match(/^NN|^PRP/) && e[1].upcase != e[1]
    end > 0
  end

  def self.contains_bad_it(point)
    return false unless point["Lemmas"].map { |l| l.split(":").first}.include? "it"
    clean_text = point["String"].downcase
    return false if clean_text.include? "act on it"
    !clean_text.match(/(and|but|whether)\sit\s/)
  end

  def self.boring_words(point, count)
    point["Lemmas"].count do |e|
      next unless e.match(/\w/)
      e = e.split(":")
      e[2].match(/^NN|^JJ|RB/)
    end < count
  end
end
