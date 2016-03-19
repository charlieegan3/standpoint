require "json"
require "pry"
require "differ"

require_relative 'presenter'
require_relative 'condense'

paragraph = "In a debate about Abortion. "

data = JSON.parse(File.open('summary.json').read)

paragraph += "Counter points like: "
data["counter_points"].each_with_index do |points, index|
  p, c = points
  result = Condense.condense_group([p["String"], c["String"]])
  if result.size == 2
    paragraph += '"' + Presenter.clean(p["String"])[0..-2] + '"'
    paragraph += " vs. "
    paragraph += '"' + Presenter.clean(c["String"])[0..-2] + '"'
  else
    paragraph += '"' + result.first[0..-2] + '"'
  end
  paragraph += "; " if index < data["counter_points"].size-2
  paragraph += " and " if index == data["counter_points"].size-2
end
paragraph += " are made."

paragraph += "\n\n"

paragraph += "These points often occurred together: "
data["related_points"].each_with_index do |points, index|
  p, r = points
  paragraph += '"' + Presenter.clean(p["String"])[0..-2] + '"'
  paragraph += " / "
  paragraph += '"' + Presenter.clean(r["String"])[0..-2] + '"'

  paragraph += "; " if index < data["related_points"].size-2
  paragraph += " and " if index == data["related_points"].size-2
end
paragraph += "."

paragraph += "\n\n"

paragraph += "Users disagree on these topics: "
data["negated_points"].each_with_index do |point, index|
  paragraph += '"' + Presenter.clean(point.first) + '"'

  paragraph += "; " if index < data["negated_points"].size-2
  paragraph += " and " if index == data["negated_points"].size-2
end
paragraph += "."

paragraph += "\n\n"

paragraph += "Other common points are: "
data["common_points"].each_with_index do |p, index|
  paragraph += '"' + Presenter.clean(p["String"]) + '"'

  paragraph += "; " if index < data["common_points"].size-2
  paragraph += " and " if index == data["common_points"].size-2
end
paragraph += "."

paragraph += "\n\n"

paragraph += "These points commonly link topics: "
data["longer_points"].each do |p|
  paragraph += '"' + Presenter.clean(p["String"]) + '"'
  paragraph += "; "
end
data["multiple_topic_points"].each_with_index do |p, index|
  paragraph += '"' + Presenter.clean(p["String"]) + '"'

  paragraph += "; " if index < data["multiple_topic_points"].size-2
  paragraph += " and " if index == data["multiple_topic_points"].size-2
end
paragraph += "."
paragraph += "\n\n"

data["commonly_discussed_topic_points"].each_with_index do |topic, index|
  topic, points = topic
  paragraph += "On the topic \"" + topic.capitalize + "\", people say: "
  points.each_with_index do |p, index|
    paragraph += '"' + Presenter.clean(p["String"]) + '"'
    paragraph += "; " if index < data["commonly_discussed_topic_points"].size-2
    paragraph += " and " if index == data["commonly_discussed_topic_points"].size-2
  end
  paragraph += ". "
end

paragraph += "\n\n"

paragraph += "People ask questions like: "
data["question_points"].each_with_index do |p, index|
  paragraph += '"' + Presenter.clean(p["String"], true) + '"'
  paragraph += "; " if index < data["question_points"].size-2
  paragraph += " and " if index == data["question_points"].size-2
end
paragraph += "."

puts paragraph
