require 'json'
require 'pry'
require 'net/http'

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

def sorted_dup_hash(array)
  Hash[*array.inject(Hash.new(0)) { |h,e| h[e] += 1; h }.
    select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }.
    sort_by {|_,v| v}.reverse.flatten]
end

def print_string(string)
  string = string.strip
    .gsub(/\s+(n?[,'\.])/, '\1')
    .gsub("-LRB-", "(").gsub("-RRB-", ")")
    .gsub("( ", "(").gsub(" )", ")")
    .gsub("-LSB-", "[").gsub("-RSB-", "]")
    .gsub("[ ", "[").gsub(" ]", "]").strip
  string = "#{string[0].upcase}#{string[1..-1]}"
  string.gsub!(/[;.]+/, "")
  string.gsub!(" ,", "")
  string = string.strip
  string += "." if string.strip[-1] != "."
  string
end

def present_point(string)
  string.gsub!(/^\W+/, "")
  string.gsub!(/ ?- ?\.?$/, "")
  string.gsub!(/[\s;\.,]+$/, "")
  string = print_string(string)
end

def relations_and_lemmas_from_parse(parse)
  relations = parse.last.group_by { |r| r["dependent"] }
    .map { |k, v| [k-1, v.map { |r| r["dep"] }] }
    .sort_by { |index, _| index }
    .map(&:last).map { |r| r.join("|") }
  return relations, parse.first.map { |t| t["lemma"] + ":" + t["originalText"] }
end

#-------------------------------------------------------------------------------
cnc = CoreNLPClient.new("http://local.docker:9000")

points = File.open(ARGV[0]).readlines[1..-1].map { |l| JSON.parse(l) }.shuffle
groups = points.group_by { |p| p["Components"].join(" ") }.reject { |_, g| g.size < 3 }
groups = groups.sort_by { |k, v| v.size }.reverse

groups.each do |k, v|
  puts k.upcase

  v.uniq! { |p| p["String"] }

  v.each do |point|
    parse = cnc.request_parse(print_string(point["String"])).first
    point["Relations"], point["Lemmas"] = relations_and_lemmas_from_parse(parse)
  end

  top_point = v.reject do |point|
    !point["String"].length.between?(25, 100) ||
    point["String"].include?("this") ||
    point["String"].include?("And") ||
    point["String"].scan(/[a-z]+[0-9A-Z]/).size > 0 ||
    point["Relations"].include?("advcl") ||
    point["Relations"].include?("dep") ||
    point["String"].scan(/[LR]RB|[LR]SB/).size.odd? ||
    point["String"].match(/^\w+ ?, /) ||
    point["String"].gsub(" ", "").match(/,{2,}/) ||
    point["String"].match(/([A-Z]+ ){2,}/) ||
    point["String"].match(/^(if|and|but|or|just|after|before|their|his|her|why)/i) ||
    point["Relations"].count { |r| r.match(/conj|nmod|acl/) } > 2
  end.sort_by { |p| p["String"].length }.last

  puts present_point(top_point["String"])
end
