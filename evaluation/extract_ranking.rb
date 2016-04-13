require 'pry'

def sorted_dup_hash(array)
  Hash[*array.inject(Hash.new(0)) { |h,e| h[e] += 1; h }.
    select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }.
    sort_by {|_,v| v}.reverse.flatten]
end


def self.bigrams(string)
  words = string.downcase.gsub(/[^\s\w']/, "").split(/\s+/)
  words.each_with_index.to_a[0..-2].map do |e, i|
    [e, words[i+1]].join(" ")
  end
end

def score_group(points)
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
  end
end

bigram_scored_extracts = []
Dir.glob('extracts/*') do |p|
  File.open(p).read.split('------').each do |group|
    extracts = group.split("\n").reject { |l| l.length < 2 || l[0].match(/\W/) }
    bigram_scored_extracts += score_group(extracts.map { |e| { "String" => e } }).map { |e| [e["String"], e["Score"]] }
  end
end
bigram_scored_extracts = Hash[*bigram_scored_extracts.flatten]
human_scored_extracts = Hash[*File.open('scored_extracts.txt').readlines.map { |x| [x[4..-1].strip, x[0..2].to_f] }.flatten]

bigram_scored_extracts.each do |k, v|
  raise if human_scored_extracts[k].nil?
  puts [v, human_scored_extracts[k]].join(", ")
end
