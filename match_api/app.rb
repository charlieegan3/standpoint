require 'json'
require 'net/http'

require 'sinatra'
require 'pry'

require './lib/client'
require './lib/graph'
require './lib/node'
require './lib/edge'

set :port, ENV['PORT']
set :bind, '0.0.0.0'
set :public_folder, 'static'

client = Client.new("http://corenlp_server:#{ENV['CNLP_PORT']}")
post '/' do
  sentence = JSON.parse(request.body.read)['sentence']
  graph = Graph.new *client.request_parse(sentence)

  {
    points: graph.nodes.map(&:point_strings).flatten,
    nodes: graph.nodes.map { |n| n.to_hash(include_edges: true) },
    edges: graph.edges.map(&:to_hash)
  }.to_json
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end
