require 'json'
require 'erb'

require 'pry'
require 'differ'
require 'levenshtein'

require_relative 'summary'
require_relative 'utils'
require_relative 'related'
require_relative 'counters'
require_relative 'curator'
require_relative 'condense'
require_relative 'presenter'
require_relative 'paragraphizer'

title = ARGV[0].scan(/(\w+)_p/).flatten.first
  .gsub(/(.)([A-Z])/,'\1 \2').split(" ").map(&:capitalize).join(" ")

out_file_name = title.split(/\W+/).join("_").downcase
in_file_name = title.split(" ").map(&:capitalize).join.tap { |e| e[0] = e[0].downcase }

lines = File.open(ARGV[0]).readlines
topics = lines.first.split(",").map(&:strip)
points = lines[2..-1].map { |l| JSON.parse(l) }
summary = Summary.new(title, points, topics, 3)
summary.build

@title = title
@summary = summary

erb = ERB.new(File.open("template_formatted.html.erb").read, 0, '>')
html = erb.result binding
File.open(out_file_name + "_formatted.html", "w") { |file| file.write(html) }
