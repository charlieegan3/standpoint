require 'json'
require 'pry'

require './lib/client'
require './lib/graph'
require './lib/node'

groups= JSON.parse(File.open('groups.json', 'r').read)
client = Client.new("http://corenlp_server:#{ENV['CNLP_PORT']}")


def sorted_dup_hash(array)
  Hash[*array.inject(Hash.new(0)) { |h,e| h[e] += 1; h }.
  select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }.
  sort_by {|_,v| v}.reverse.flatten]
end


labels = []
pos = []

groups.each do |k, v|
  v['frames'].each do |f|
    next unless f['pattern'].include? "S-Quote"
    f['examples'].each do |sentence|
      graph = Graph.new *client.request_parse(sentence)
      first = graph.nodes.select {|n| n.pos.match(/VB/)}.first
      next unless first
      # first.outbound.map(&:print)
      matching = first.outbound.select { |x|
        (x.destination.pos.match(/cats/) ||
        x.label.match(/dep|comp/)) && x.destination.index > first.index
      }
      next if matching.empty?

      labels += matching.map(&:label)
      pos += matching.map(&:destination).map(&:pos)
    end
  end
end

puts sorted_dup_hash(labels)
puts sorted_dup_hash(labels).keys.join("|")
puts
puts sorted_dup_hash(pos)
puts sorted_dup_hash(pos).keys.join("|")
