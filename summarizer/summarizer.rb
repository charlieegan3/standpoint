require 'pry'
require 'json'
require 'differ'
require 'levenshtein'
require 'erb'
require 'nokogiri'

require_relative 'summary'

require_relative 'utils'

require_relative 'related'
require_relative 'counters'
require_relative 'curator'
require_relative 'condense'
require_relative 'presenter'

title = ARGV[0].scan(/\/(\w+)_p/).flatten.first
  .gsub(/(.)([A-Z])/,'\1 \2').split(" ").map(&:capitalize).join(" ")
lines = File.open(ARGV[0]).readlines
topics = lines.first.split(",").map(&:strip)
points = lines[2..-1].map { |l| JSON.parse(l) }
summary = Summary.new(title, points, topics, 3)
summary.build

@title = title
@summary = summary
@stock_summary = ""

erb = ERB.new(File.open("template.html.erb").read, 0, '>')
html = erb.result binding
word_count = Nokogiri::HTML(html).text.split(/\s+/).size

file_name = title.split(" ").map(&:capitalize).join
file_name = file_name[0].downcase + file_name[1..-1]
@stock_summary = `python ../stock_summarizers/nlp_course/summarizer_topic.py #{file_name} #{word_count}`

html = erb.result binding
File.open(title.downcase.gsub(/\W+/, "_") + "_summary.html", "w") { |file| file.write(html) }
File.open(title.downcase.gsub(/\W+/, "_") + "_summary.json", "w") { |file| file.write(summary.to_h.to_json) }
