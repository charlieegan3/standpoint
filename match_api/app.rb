require 'json'
require 'net/http'
require 'pry'

require './lib/client'
require './lib/graph'
require './lib/node'
require './lib/edge'

sentences = [
  "They went to Paris as well as Berlin.",
].each do |sentence|
  client = Client.new("http://corenlp_server:#{ENV['CNLP_PORT']}")
  graph = Graph.new *client.request_parse(sentence)

  puts "Parse:"
  graph.nodes.each do |node|
    node.outbound.each { |e|print "   "; e.print }
  end
  puts "Verbs:"
  graph.nodes.each do |node|
    next unless node.pos.match(/VB/)
    print "   " + node.word.upcase + ": "
    puts node.descendants.sort_by(&:index).map(&:word).join(" ")
  end

  puts "-"*50
end
