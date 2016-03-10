require 'pry'
require 'json'

require_relative 'utils'

require_relative 'related'
require_relative 'counters'
require_relative 'curator'

def c(string)
  Curator.clean_string(string)
end

antonyms = JSON.parse(File.open("antonyms.json").read)
points = File.open(ARGV[0]).readlines[1..-1].map { |l| JSON.parse(l) }

groups = Hash[*points.group_by { |p| p["Components"] }.sort_by { |_, v| v.size }.reverse.flatten(1)]
reference_groups = groups.dup

related = Related.related_points(points)
used_points = []
related.reject! { |p| used = p.first.map { |e| used_points.include?(e) }.any?; used_points += p.first unless used; used }
counters = Counters.counter_points(points)

selected_related = related.take(3).map(&:first)
selected_counters = counters.take(3).map { |k, v| [k, v.first] }

(selected_counters + selected_related).flatten(1).uniq.each do |point|
  groups.delete(point)
end

selected_top = groups.keys.take(3)

post_count = points.map { |p| p["Post"] }.uniq.size
group_count = groups.select { |k, v| v.size > 1 }.size
puts "Summary based on #{points.size} points from #{post_count} posts. There were #{group_count} groups of equivalent points."

puts "The following contrasting points were discussed:"
selected_counters.each do |point, counter|
  point = Curator.select_best(reference_groups[point])["String"]
  counter = Curator.select_best(reference_groups[counter])["String"]
  puts "  * \"#{c(point)}\" & \"#{c(counter)}\""
end

puts "These were common pairs of points raised by the same user:"
selected_related.each do |point, related|
  point = Curator.select_best(reference_groups[point])["String"]
  related = Curator.select_best(reference_groups[related])["String"]
  puts "  * \"#{c(point)}\" & \"#{c(related)}\""
end

puts "Other common points made in the discussion were:"
selected_top.each do |point|
  point =  Curator.select_best(reference_groups[point])["String"]
  puts "  * \"#{c(point)}\""
end
