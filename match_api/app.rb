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
  points, frames = graph.points(verbs)
  {
    points: points.map(&:to_hash),
    frames: frames,
    verbs: graph.verbs.map { |v| { verb: v.word, string: v.tree.sort_by(&:index).map(&:word).join(" ") } }
  }.to_json
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end
