require 'json'
require 'net/http'
require 'pry'

require './lib/client'
require './lib/graph'
require './lib/node'
require './lib/edge'

sentence = ARGV[0]
exit unless sentence

client = Client.new("http://corenlp_server:#{ENV['CNLP_PORT']}")
graph = Graph.new *client.request_parse(sentence)

print "Input:\n   "
puts sentence
puts "Parse:"
graph.nodes.each do |node|
  node.outbound.each { |e| print "   "; e.print }
end
puts "Verbs:"
graph.nodes.each do |node|
  next unless node.pos.match(/VB/)
  puts "   " + node.word.upcase + ":"
  node.points.each do |point|
    print "      "
    puts point.sort_by(&:index).map(&:word).join(" ")
  end
end
