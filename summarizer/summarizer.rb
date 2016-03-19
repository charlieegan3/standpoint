require 'pry'
require 'json'
require 'differ'
require 'levenshtein'
require 'erb'

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
erb = ERB.new(File.open("template.html.erb").read, 0, '>')
html = erb.result binding
File.open(title.downcase + "_summary.html", "w").write(html)
