require 'pry'

module Enumerable
  def sum
	self.inject(0){|accum, i| accum + i }
  end

  def mean
	self.sum/self.length.to_f
  end

  def sample_variance
	m = self.mean
	sum = self.inject(0){|accum, i| accum +(i-m)**2 }
	sum/(self.length - 1).to_f
  end

  def standard_deviation
	return Math.sqrt(self.sample_variance)
  end
end

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
human_scored_extracts = Hash[*File.open('scored_extracts.txt').readlines.map { |x| [[x[x.index(",")+2..-2]], x[0..x.index(",")-1].to_f] }.flatten]

puts "bigram, turkers"
bigram_scored_extracts.each do |k, v|
  raise if human_scored_extracts[k].nil?
  puts [v.round(3), human_scored_extracts[k]].join(", ")
end
exit

machine_mean = bigram_scored_extracts.values.mean
machine_stdev = bigram_scored_extracts.values.standard_deviation

machine_for_each_human_score = Hash.new([])
File.open('scored_extracts_all.txt').readlines.map { |l| l.split("||") }.each do |e, scores|
  next unless e.strip.length > 0
  scores.strip.split(",").map(&:to_i).each do |s|
    machine_score = bigram_scored_extracts[e]
    raise if machine_score.nil?
    machine_for_each_human_score[s] += [((machine_score - machine_mean) / machine_stdev).round(2)]
  end
end

machine_for_each_human_score[1] += machine_for_each_human_score.delete(0)

machine_for_each_human_score.sort_by { |k, _| k }.each do |k, v|
  puts "r#{k} = c(#{v.join(",")})"
end
