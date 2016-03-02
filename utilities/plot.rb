require "pry"
require "json"

def sorted_dup_hash(array)
  Hash[*array.inject(Hash.new(0)) { |h,e| h[e] += 1; h }.
  select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }.
  sort_by {|_,v| v}.reverse.flatten]
end

data = JSON.parse(File.open("summary.json").read.downcase).take(30)
patterns = data.map { |x| x["pattern"].split(" ").map{|x|x.split(".").first }}

words, verbs = [], []
data.each do |point|
  point["count"].times do
    point["pattern"].split(" ").map{ |x| x.split(".") }.each do |word, rel|
      words << word
      verbs << word if rel == "verb"
    end
  end
end
verbs.uniq!

words = Hash[*sorted_dup_hash(words).map { |k, v| [k, Math::log(v).round(2) * 50] }.flatten]
nodes = words.map do |k, v|
  {
    id: k,
    value: k,
    weight: v,
    type: verbs.include?(k) ? "verb" : "",
  }
end

edges = []
patterns.each do |pattern|
  if pattern.size == 2
    edges << { source: pattern.first, target: pattern.last, label: ""}
  elsif pattern.size == 3
    edges << { source: pattern.first, target: pattern.last, label: pattern[1].split(".").first}
  elsif pattern.size == 4
    edges << { source: pattern.first, target: pattern[1], label: ""}
    edges << { source: pattern[1], target: pattern[3], label: pattern[2].split(".").first}
  elsif pattern.size == 5
    edges << { source: pattern.first, target: pattern[2], label: pattern[1].split(".").first}
    edges << { source: pattern[2], target: pattern[4], label: pattern[3].split(".").first}
  end
end
edges.uniq!

in_relationship = []
edges.each do |e|
  in_relationship += [e[:source], e[:target]]
end

nodes.select! { |n| in_relationship.include?(n[:id]) }

nodes.map! { |e| { data: e } }
edges.map! { |e| { data: e } }
puts Hash[:elements, { nodes: nodes, edges: edges }].to_json[1..-2]
