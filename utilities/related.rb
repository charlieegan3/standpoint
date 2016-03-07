require 'pry'
require 'json'

def sorted_dup_hash(array)
  Hash[*array.inject(Hash.new(0)) { |h,e| h[e] += 1; h }.
    select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }.
    sort_by {|_,v| v}.reverse.flatten]
end

lines = File.open(ARGV[0]).readlines[1..-1].map { |l| JSON.parse(l) }
points = lines.map { |p| p["Components"].join(" ") }.uniq
posts = lines.group_by { |p| p["Post"] }

ptoi = {}
itop = {}
points.each_with_index { |v, i| ptoi[v] = i; itop[i] = v }

posts = posts.map { |k, v| v.map { |p| ptoi[p["Components"].join(" ")] }.uniq }

related = Hash.new(0)
posts.each do |p|
  p.combination(2).to_a.each do |c|
    related[c] += 1
  end
end

related = related.reject { |k,v| v < 3 }
related = related.sort_by { |k, v| v }.reverse

related.map do |points, count|
  points.map! { |p| itop[p].split(" ") }
  if (points.first & points.last).size > 1
    next
  end
  puts "#{count} times: \n    #{points.map { |p| p.join(" ") }.join("\n    ")}"
end
