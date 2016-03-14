require 'pry'
require 'json'
require 'differ'

require_relative 'utils'

require_relative 'related'
require_relative 'counters'
require_relative 'curator'
require_relative 'condense'

def c(string, question=false)
  Curator.clean_string(string, question)
end

antonyms = JSON.parse(File.open("antonyms.json").read)
lines = File.open(ARGV[0]).readlines
topics = lines.first.split(",")
points = lines[2..-1].map { |l| JSON.parse(l) }

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

puts "\nThe following contrasting points were discussed:"
count = 0
selected_counters.each do |point, counter|
  point = Curator.select_best(reference_groups[point])
  counter = Curator.select_best(reference_groups[counter])
  next if [point, counter].map(&:nil?).any?
  puts "  * \"#{c(point["String"])}\" & \"#{c(counter["String"])}\""
  displayed_points += [point, counter].map { |p| p["Components"] }
  break if (count += 1) > 2
end

puts "\nThese were common pairs of points raised by the same user:"
count = 0
selected_related.each do |point, related|
  point = Curator.select_best(reference_groups[point])
  related = Curator.select_best(reference_groups[related])
  next if [point, related].map(&:nil?).any?
  puts "  * \"#{c(point["String"])}\" & \"#{c(related["String"])}\""
  displayed_points += [point, related].map { |p| p["Components"] }
  break if (count += 1) > 2
end

puts "\nOther common points made in the discussion were:"
count = 0
(groups.keys - displayed_points).each do |point|
  point =  Curator.select_best(reference_groups[point])
  next if point.nil?
  puts "  * \"#{c(point["String"])}\""
  break if (count += 1) > 2
end

puts "\nLonger form points made in the discussion were:"
count = 0
listed = []
(groups.reject { |k, v| k.size < 4 || v.size < 3 }.sort_by { |_, v| 1.0/v.size }.map(&:first) - displayed_points).each do |point|
  point =  Curator.select_best(reference_groups[point])
  next if point.nil? || listed.include?(c(point["String"]))
  listed << c(point["String"])
  puts "  * \"#{listed.last}\""
  break if (count += 1) > 2
end

puts "\nPoints for commonly discussed topics:"
top_topics = Curator.sorted_dup_hash(groups.keys.flatten.map(&:downcase))
               .keys
               .select { |e|
                 e.match(/nsubj|dobj/) &&
                 !e.match(/person|they|\.verb|\.prep|it\.|what\.|that\.|one\./)
               }.map { |e| e.split(".").first }
               .uniq
top_topics.take(3).each do |t|
  puts " -#{t}"
  strings = groups.select { |k, _| k.join.include? t }.take(5).map do |k, group|
    point = Curator.select_best(group)
    next if point.nil?
    c(point["String"])
  end.compact

  Condense.condense_group(strings).sort_by { |s| s.index("{") || 1000 }.take(3).each do |s|
    puts "  * " + s
  end
end

puts "\nTop points about multiple topics:"
topic_points = points.sort_by { |p| topics.count { |t| p["String"].downcase.include? t } }.reverse.take(100)
used_topic_points = []
for i in 0..10
  point = topic_points.delete(Curator.select_best(topic_points))
  break unless point
  if used_topic_points.include? c(point["String"])
    i -= 1
    next
  end
  used_topic_points << c(point["String"])
  puts "  * \"#{c(point["String"])}\""
  break if used_topic_points.size > 5
end

puts "\nPeople ask questions like:"
question_groups = points.select { |p| p["String"].include? "?" }
      .uniq {|p| p["String"] }
      .group_by { |p| p["Components"] }
      .sort_by { |k, v| v.size }
      .select { |k, v| v.size > 2 }
question_groups.each do |pattern, group|
  top_question = Curator.select_best_question(group)
  next unless top_question
  puts "  * \"#{c(top_question["String"], true)}\""
end
