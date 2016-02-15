require 'json'
require 'net/http'

require 'sinatra'
require 'neo4j'
require 'pry'

require './lib/corenlp_client'
require './lib/neo4j_client'
require './lib/frame'
require './lib/node'
require './lib/relation'

set :port, ENV['PORT']
set :bind, '0.0.0.0'
set :public_folder, 'static'

corenlp_client = CoreNlpClient.new("http://corenlp_server:#{ENV['CNLP_PORT']}")
neo4j_client = Neo4jClient.new("http://neo4j:7474")

verbs = JSON.parse(File.open('verbs.json', 'r').read)
frame_queries = Hash[*Dir.glob('frame_queries/*.cql').map do |path|
  [path.scan(/\/(\w+)\./)[0][0].humanize.upcase,
    File.open(path, 'r').read]
end.flatten]

post '/' do
  sentence = JSON.parse(request.body.read)['sentence']
  tokens, dependencies = corenlp_client.request_parse(sentence)
  neo4j_client.clear
  neo4j_client.create(tokens, dependencies)

  points = []
  neo4j_client.verbs.each do |verb|
    verbs[verb.lemma].each do |frame|
      frame = Frame.new(frame, verb.lemma)
      next unless query = frame_queries[frame.pos_pattern_string]
      match = neo4j_client.query(verb, query)
      next if match.to_a.empty?
      points << match.zip(frame.components).map { |m, c| { match: m, component: c } }
    end
  end
  points.uniq.to_json
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end
