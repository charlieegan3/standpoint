require 'pry'
require 'json'
require 'differ'
require 'levenshtein'

require_relative 'utils'

require_relative 'related'
require_relative 'counters'
require_relative 'curator'
require_relative 'condense'

def c(string, question=false)
  Curator.clean_string(string, question)
end

summary_string = ARGV[0].scan(/\/(\w+)_p/).flatten.first
  .gsub(/(.)([A-Z])/,'\1 \2').split(" ").map(&:capitalize).join(" ")

antonyms = JSON.parse(File.open("antonyms.json").read)
lines = File.open(ARGV[0]).readlines
topics = lines.first.split(",").map(&:strip)
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
summary_string += "\nSummary based on __#{points.size} points__ from __#{post_count} posts__. There were __#{group_count} groups__ of equivalent points."

displayed_points = []

summary_string += "\nThe following __contrasting points__ were discussed:"
count = 0
selected_counters.each do |point, counter|
  point = Curator.select_best(reference_groups[point])
  counter = Curator.select_best(reference_groups[counter])
  next if [point, counter].map(&:nil?).any?
  condensed = Condense.condense_group([point["String"], counter["String"]])
  if condensed.size == 1
    summary_string += "\n  * #{condensed.first}"
  else
    summary_string += "\n  * \"#{c(point["String"])}\" vs. \"#{c(counter["String"])}\""
  end

  displayed_points += [point, counter].map { |p| p["Components"] }
  break if (count += 1) > 2
end

summary_string += "\nThe following __negated points__ were discussed:"
count = 0
groups.each do |k, v|
  counter_point_groups = Counters.negated_points(v)
  next if counter_point_groups.empty?
  best = counter_point_groups.map { |g| g.min_by(&:length) }.min_by { |s| s.scan(/\||\{|\}/).size }
  next unless best
  count += 1
  best = c(Condense.format_match_string(Condense.merge_diff_groups(best)))
  summary_string += "\n  * #{best}"
  break if count > 4
end

summary_string += "\nThese pairs of points were often __raised in conjunction with one another__:"
count = 0
selected_related.each do |point, related|
  point = Curator.select_best(reference_groups[point])
  related = Curator.select_best(reference_groups[related])
  next if [point, related].map(&:nil?).any?
  summary_string += "\n  * \"#{c(point["String"])}\" & \"#{c(related["String"])}\""
  displayed_points += [point, related].map { |p| p["Components"] }
  break if (count += 1) > 2
end

summary_string += "\nOther __commonly occurring points__ made in the discussion were:"
count = 0
(groups.keys - displayed_points).each do |point|
  point =  Curator.select_best(reference_groups[point])
  next if point.nil?
  summary_string += "\n  * \"#{c(point["String"])}\""
  break if (count += 1) > 2
end

summary_string += "\nCommon points made in the discussion that __link topics__ were:"
count = 0
listed = []
(groups.reject { |k, v| k.size < 4 || v.size < 3 }.sort_by { |_, v| 1.0/v.size }.map(&:first) - displayed_points).each do |point|
  point =  Curator.select_best(reference_groups[point])
  next if point.nil? || listed.include?(c(point["String"]))
  listed << c(point["String"])
  break if (count += 1) > 5
end

Condense.condense_group(listed).take(3).each do |string|
  summary_string += "\n  * \"#{string}\""
end

summary_string += "\nPoints for __commonly discussed topics__:"
top_topics = Utils.sorted_dup_hash(groups.keys.flatten.map(&:downcase))
               .keys
               .select { |e|
                 e.match(/nsubj|dobj/) &&
                 !e.match(/person|they|\.verb|\.prep|it\.|what\.|that\.|one\./)
               }.map { |e| e.split(".").first }
               .uniq
top_topics.take(3).each do |t|
  summary_string += "\n-#{t.downcase.capitalize}"
  strings = groups.select { |k, _| k.join(" ").include? " #{t}." }.take(5).map do |k, group|
    point = Curator.select_best(group)
    next if point.nil?
    c(point["String"])
  end.compact

  Condense.condense_group(strings).take(3).each do |s|
    summary_string += "\n    * " + s
  end
end

summary_string += "\nPoints about __multiple topics__:"
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
  break if used_topic_points.size > 5
end

Condense.condense_group(used_topic_points).each do |s|
  summary_string += "\n  * \"#{s}\""
end

summary_string += "\nPeople ask __questions__ like:"
question_groups = points.select { |p| p["String"].include? "?" }
      .uniq {|p| p["String"] }
      .group_by { |p| p["Components"] }
      .sort_by { |k, v| v.size }
      .select { |k, v| v.size > 2 }
question_groups.each do |pattern, group|
  top_question = Curator.select_best_question(group)
  next unless top_question
  summary_string += "\n  * \"#{c(top_question["String"], true)}\""
end


summary_string.gsub!("*", ">")
summary_string.gsub!("__", "**")
summary_string.gsub!(/^\-/, " * ")
lines = summary_string.split("\n")
lines[0] = "# " + lines[0]
lines << lines.delete_at(1)
lines.map! do |l|
  next unless l
  l = l[0].match(/\w/) ? "\n#{l}" : l
  if l.length > 80 && l.include?("&")
    l = l.split(/\s&\s/).join("\n> & \n> ")
  end
  l
end
lines[-1] = "***\n" + lines[-1]

summary_string = lines.join("\n\n")
summary_string.gsub!(' & ', " **&** ")
summary_string.gsub!(' vs. ', " **vs.** ")
summary_string.gsub!('{', " **{** ")
summary_string.gsub!('}', " **}** ")
summary_string.gsub!('|', " **or** ")
summary_string.gsub!('"', "")
summary_string.gsub!('"', "")
regex = topics.sort_by(&:length).reverse.join("|")
summary_string.gsub!(/(^.*>.*\W)(#{regex})(\W)/i, '\1`\2`\3')

puts summary_string



