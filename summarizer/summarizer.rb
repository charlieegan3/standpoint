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

selected_related = related.map(&:first)
selected_counters = counters.map { |k, v| [k, v.first] }


post_count = points.map { |p| p["Post"] }.uniq.size
group_count = groups.select { |k, v| v.size > 1 }.size
puts "Summary based on #{points.size} points from #{post_count} posts. There were #{group_count} groups of equivalent points."

displayed_points = []

puts "The following contrasting points were discussed:"
count = 0
selected_counters.each do |point, counter|
  point = Curator.select_best(reference_groups[point])
  counter = Curator.select_best(reference_groups[counter])
  next if [point, counter].map(&:nil?).any?
  puts "  * \"#{c(point["String"])}\" & \"#{c(counter["String"])}\""
  displayed_points += [point, counter].map { |p| p["Components"] }
  break if (count += 1) > 2
end

puts "These were common pairs of points raised by the same user:"
count = 0
selected_related.each do |point, related|
  point = Curator.select_best(reference_groups[point])
  related = Curator.select_best(reference_groups[related])
  next if [point, related].map(&:nil?).any?
  puts "  * \"#{c(point["String"])}\" & \"#{c(related["String"])}\""
  displayed_points += [point, related].map { |p| p["Components"] }
  break if (count += 1) > 2
end

puts "Other common points made in the discussion were:"
count = 0
(groups.keys - displayed_points).each do |point|
  point =  Curator.select_best(reference_groups[point])
  next if point.nil?
  puts "  * \"#{c(point["String"])}\""
  break if (count += 1) > 2
end
