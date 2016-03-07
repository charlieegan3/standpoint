require 'pry'
require 'json'

def sorted_dup_hash(array)
  Hash[*array.inject(Hash.new(0)) { |h,e| h[e] += 1; h }.
    select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }.
    sort_by {|_,v| v}.reverse.flatten]
end

lines = File.open(ARGV[0]).readlines[1..-1].map { |l| JSON.parse(l) }
points = lines.map { |p| p["Components"].join(" ") }.uniq
groups = lines.group_by { |p| p["OriginalStanceText"] }

groups.each { |k,v| groups[k] = v.map { |p| p["Components"].join(" ") } }

common = groups.values.reduce(&:&)
groups.each { |k,v| groups[k] = (v - common) }

groups.each do |k, v|
  puts k
  sorted_dup_hash(v).to_a.take(10).each do |k, v|
    puts "   #{v}: #{k}"
  end
  puts
end
