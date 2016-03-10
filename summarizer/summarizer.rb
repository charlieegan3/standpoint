require 'pry'
require 'json'

require_relative 'utils'

require_relative 'related'
require_relative 'counters'
require_relative 'curator'

antonyms = JSON.parse(File.open("antonyms.json").read)
points = File.open(ARGV[0]).readlines[1..-1].map { |l| JSON.parse(l) }

groups = Hash[*points.group_by { |p| p["Components"] }.sort_by { |_, v| v.size }.reverse.flatten(1)]
reference_groups = groups.dup

related = Related.related_points(points)
counters = Counters.counter_points(points)

selected_related = related.take(2).map(&:first)
selected_counters = counters.take(2).map { |k, v| [k, v.first] }

(selected_counters + selected_related).flatten(1).uniq.each do |point|
  groups.delete(point)
end

selected_top = groups.keys.take(2)

puts "Counters"
selected_counters.each do |point, counter|
  p Curator.select_best(reference_groups[point])["String"]
  p Curator.select_best(reference_groups[counter])["String"]
end

puts "Related"
selected_related.each do |point, related|
  p Curator.select_best(reference_groups[point])["String"]
  p Curator.select_best(reference_groups[related])["String"]
end

puts "Rest"
selected_top.each do |point|
  p Curator.select_best(reference_groups[point])["String"]
end
