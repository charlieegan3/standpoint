require 'json'
require 'net/http'

require 'pry'

class Node
  attr_accessor :word, :pos, :lemma, :index, :inbound, :outbound

  def initialize(word, pos, lemma, index)
    @word, @pos, @lemma, @index = word, pos, lemma, index
    @inbound = []
    @outbound = []
  end

  def print
    inbound.each do |e|
      e.print
    end
    outbound.each do |e|
      e.print
    end
  end

  def descendants
    outbound.map do |e|
      e.destination.descendants
    end.flatten << self
  end

  def ancestors
    inbound.map do |e|
      e.origin.ancestors
    end.flatten << self
  end

  def graph
    nodes = [self]
    outbound.map do |e|
      nodes += e.destination.descendants
      nodes += e.destination.ancestors
    end
    inbound.map do |e|
      nodes += e.origin.descendants
      nodes += e.origin.ancestors
    end
    return nodes.uniq.sort_by(&:index)
  end
end

class Edge
  attr_accessor :origin, :destination, :label

  def initialize(origin, destination, label)
    @origin, @destination, @label = origin, destination, label
  end

  def print
    puts [
      origin.word + "(#{origin.pos})",
      label,
      destination.word + "(#{destination.pos})"
    ].join(" -> ")
  end
end


def points(sentence)
  puts sentence
  params = 'properties={"annotators": "depparse", "parser.flags": " -makeCopulaHead"}'
  uri = URI("http://corenlp_server:#{ENV['CNLP_PORT']}/?" + URI.encode(params))
  http = Net::HTTP.new(uri.host, uri.port)

  req = Net::HTTP::Post.new(uri)
  req.body = sentence
  response = JSON.parse(http.request(req).body)['sentences'].first

  deps = response['basic-dependencies']
  tokens = response['tokens']

  nodes = tokens.map { |t| [t['word'], t['pos'], t['lemma'], t['index'].to_i-1] }
  edges = deps.map {|d| [d['dep'], d['governor'].to_i-1, d['dependent'].to_i-1] }

  blacklist = %w(ROOT)
  edges.reject! { |l,g,d| blacklist.include?(l) }

  nodes.map! { |w,p,l,i| Node.new(w, p, l, i) }
  edges.map! { |l,g,d|
    e = Edge.new(nodes[g], nodes[d], l)
    nodes[g].outbound << e
    nodes[d].inbound << e
  }

  puts "Parse:"
  nodes.each do |node|
    node.outbound.each { |e|print "   "; e.print }
  end
  puts "Verbs:"
  nodes.each do |node|
    next unless node.pos.match(/VB/) || !node.outbound.map(&:label).select {|x|x=="cop"}.empty?

    print "   " + node.word.upcase + ": "
    puts node.descendants.sort_by(&:index).map(&:word).join(" ")
  end

  puts "-"*50
end

sentences = [
  "She is British.",
  "The man went to the shop"
].map {|s|points(s)}
