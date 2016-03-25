require "json"
require "pry"
require "differ"
require "erb"

require_relative 'presenter'
require_relative 'condense'

def generate_paragraph(data)
  paragraph = ""
  data["counter_points"].each_with_index do |points, index|
    p, c = points
    paragraph += '"' + Presenter.clean(p["String"])[0..-2] + '"'
    paragraph += ", " if index < data["counter_points"].size-1
  end

  paragraph += "\n"

  data["related_points"].each_with_index do |points, index|
    p, r = points
    paragraph += '"' + Presenter.clean(p["String"])[0..-2] + '"'
    paragraph += ", "
    paragraph += '"' + Presenter.clean(r["String"])[0..-2] + '"'

    paragraph += ", " if index < data["related_points"].size-1
  end

  paragraph += "\n"

  data["negated_points"].each_with_index do |point, index|
    paragraph += '"' + Presenter.clean(point[1]["String"]) + '"'

    paragraph += ", " if index < data["negated_points"].size-1
  end

  paragraph += "\n"

  data["common_points"].each_with_index do |p, index|
    paragraph += '"' + Presenter.clean(p["String"]) + '"'

    paragraph += ", " if index < data["common_points"].size-1
  end

  paragraph += "\n"

  data["longer_points"].each do |p|
    paragraph += '"' + Presenter.clean(p["String"]) + '"'
    paragraph += ", "
  end
  data["multiple_topic_points"].each_with_index do |p, index|
    paragraph += '"' + Presenter.clean(p["String"]) + '"'

    paragraph += ", " if index < data["multiple_topic_points"].size-1
  end
  paragraph += "\n"

  data["commonly_discussed_topic_points"].each_with_index do |topic, index|
    topic, points = topic
    points.each_with_index do |p, index|
      paragraph += '"' + Presenter.clean(p["String"]) + '"'
      paragraph += ", " if index < data["commonly_discussed_topic_points"].size-1
    end
    paragraph += "\n" unless index == data["commonly_discussed_topic_points"].size-1
  end

  paragraph += "\n"

  data["question_points"].each_with_index do |p, index|
    paragraph += '"' + Presenter.clean(p["String"], true) + '"'
    paragraph += ", " if index < data["question_points"].size-1
  end

  return paragraph
end

["abortion", "creation", "guns", "gay_rights", "healthcare", "god"].each do |d|
  data = JSON.parse(File.open(d + '_summary.json').read)
  @summary = generate_paragraph(data)
  word_count = @summary.split(/\s+/).size

  file_name = d.split("_").map(&:capitalize).join
  file_name = file_name[0].downcase + file_name[1..-1]
  @stock_summary = `python ../stock_summarizers/nlp_course/summarizer_topic.py #{file_name} #{word_count}`

  @title = d.split("_").map(&:capitalize).join(" ")

  erb = ERB.new(File.open("template_plain.html.erb").read, 0, '>')
  html = erb.result binding

  File.open(d + "_summary_plain.html", "w") { |file| file.write(html) }
end
