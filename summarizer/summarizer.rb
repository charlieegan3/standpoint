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
require_relative 'paragraphizer'

def stock_summary(debate, words)
  `python ../stock_summarizers/summarizer_topic.py #{debate} #{words}`
end

title = ARGV[0].scan(/\/(\w+)_p/).flatten.first
  .gsub(/(.)([A-Z])/,'\1 \2').split(" ").map(&:capitalize).join(" ")

out_file_name = "output/" + title.split(/\W+/).join("_").downcase
in_file_name = title.split(" ").map(&:capitalize).join.tap { |e| e[0] = e[0].downcase }

lines = File.open(ARGV[0]).readlines
topics = lines.first.split(",").map(&:strip)
points = lines[2..-1].map { |l| JSON.parse(l) }
summary = Summary.new(title, points, topics, 3)
summary.build

@title = title
@summary = summary

# generate layout summary
erb = ERB.new(File.open("template_layout.html.erb").read, 0, '>')
html = erb.result binding
full_word_count = Nokogiri::HTML(html).text.split(/\s+/).size
File.open(out_file_name + "_layout.html", "w") { |file| file.write(html) }

# generate formatted summary
erb = ERB.new(File.open("template_formatted.html.erb").read, 0, '>')
html = erb.result binding
File.open(out_file_name + "_formatted.html", "w") { |file| file.write(html) }

# generate plain summary
@summary = Paragraphizer.generate_paragraph(@summary.to_h)
erb = ERB.new(File.open("template_plain_stock.html.erb").read, 0, '>')
html = erb.result binding
plain_word_count = Nokogiri::HTML(html).text.split(/\s+/).size
File.open(out_file_name + "_plain.html", "w") { |file| file.write(html) }

# generate short stock summary
@summary = stock_summary(in_file_name, plain_word_count)
erb = ERB.new(File.open("template_plain_stock.html.erb").read, 0, '>')
html = erb.result binding
File.open(out_file_name + "_stock_short.html", "w") { |file| file.write(html) }

# generate long stock summary
@summary = stock_summary(in_file_name, full_word_count)
erb = ERB.new(File.open("template_plain_stock.html.erb").read, 0, '>')
html = erb.result binding
File.open(out_file_name + "_stock_long.html", "w") { |file| file.write(html) }
