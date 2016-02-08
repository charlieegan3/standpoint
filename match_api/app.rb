require 'json'
require 'net/http'

require 'sinatra'
require 'pry'

require './lib/client'
require './lib/graph'
require './lib/node'
require './lib/edge'
require './lib/frame'

set :port, ENV['PORT']
set :bind, '0.0.0.0'
set :public_folder, 'static'

client = Client.new("http://corenlp_server:#{ENV['CNLP_PORT']}")
verbs = JSON.parse(File.open('verbs.json', 'r').read)

post '/' do
  sentence = JSON.parse(request.body.read)['sentence']
  graph = Graph.new *client.request_parse(sentence)
  node_points = graph.nodes.map(&:points).reject(&:empty?)


  node_points.map! do |points|
    points.map do |point|
      verb = point.select { |n| n.is_verb? }.first
      return { string: point.sort_by(&:index).map(&:word).join(" "), point: point } if verb.nil?
      frames = verbs[verb.lemma].map { |f| Frame.new(f['pattern']) }.uniq { |f| f.pattern_string }
      matched_frames = frames.select do |frame|
        matched = true
        frame.relations.each do |rel|
          matched = verb.outbound.map { |edge| edge.match_relation?(rel) }.reduce(:|)
          break if matched == false
        end
        matched
      end
      {
        string: point.sort_by(&:index).map(&:word).join(" "),
        frames: matched_frames.map(&:to_hash),
        point: point.sort_by(&:index).map { |n| n.to_hash(include_edges: true) }
      }
    end
  end

  {
    points: node_points.flatten(1),
    graph_nodes: graph.nodes.map { |n| n.to_hash(include_edges: true) },
    graph_edges: graph.edges.map(&:to_hash)
  }.to_json
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end
