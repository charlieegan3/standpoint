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
puts "Verbs:"
graph.nodes.each do |node|
  points = node.points
  next if points.empty?
  puts "   " + node.word.upcase + ":"
  node.points.each do |point|
    print "      "
    puts point.sort_by(&:index).map(&:word).join(" ")

    verb = point.select { |n| n.is_verb? }.first
    frames = verbs[verb.lemma].map { |f| Frame.new(f['pattern']) }
    frames.each do |frame|
      matched = true
      frame.relations.each do |rel|
        matched = verb.outbound.map { |edge| edge.match_relation?(rel) }.reduce(:|)
        break if matched == false
      end
      puts "         " + frame.pattern_string.ljust(20) + " - " + matched.to_s
    end
  end
end
