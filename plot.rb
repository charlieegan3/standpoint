require "pry"
require "json"

def sorted_dup_hash(array)
  Hash[*array.inject(Hash.new(0)) { |h,e| h[e] += 1; h }.
  select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }.
  sort_by {|_,v| v}.reverse.flatten]
end

data = JSON.parse(File.open("summary.json").read.downcase).take(20)
patterns = data.map { |x| x["pattern"].split(" ").map{|x|x.split(".").first }}

words = []
data.each do |point|
  point["count"].times do
    words += point["pattern"].split(" ").map{|x|x.split(".").first }
  end
end

#words = Hash[*sorted_dup_hash(words).map { |k, v| [k, Math::log(v).round(2)] }.flatten]
words = Hash[*sorted_dup_hash(words).map { |k, v| [k, v] }.flatten]
nodes = words.map { |k, v| { id: k, value: k, weight: v } }

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
