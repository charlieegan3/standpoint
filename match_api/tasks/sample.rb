require 'json'
require 'net/http'
require 'pp'
require 'pry'

require './lib/client'
require './lib/graph'
require './lib/node'
require './lib/edge'
require './lib/frame'

sentence = ARGV[0]
exit unless sentence

verbs = JSON.parse(File.open('verbs.json', 'r').read)

client = Client.new("http://corenlp_server:#{ENV['CNLP_PORT']}")
graph = Graph.new *client.request_parse(sentence)

print "Input:\n   "
puts sentence
puts "Parse:"
graph.nodes.each do |node|
  node.outbound.each { |e| print "   "; e.print }
end

puts "Points:"
points = graph.points(verbs)

points.each do |point|
  point.inspect
  puts
end
