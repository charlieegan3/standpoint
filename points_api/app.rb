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
require './lib/points_extraction'

set :port, ENV['PORT']
set :bind, '0.0.0.0'
set :public_folder, 'static'

corenlp_client = CoreNlpClient.new("http://corenlp_server:#{ENV['CNLP_PORT']}")
neo4j_client = Neo4jClient.new("http://neo4j:7474")

frames = JSON.parse(File.open('verbs.json', 'r').read)
frame_queries = Hash[*Dir.glob('frame_queries/*.cql').map do |path|
  [path.scan(/\/((\w|-)+)\./)[0][0].humanize.upcase.gsub('-COPULA', '-cop'),
    File.open(path, 'r').read]
end.flatten]

post '/' do
  data = JSON.parse(request.body.read)
  sentences = corenlp_client.request_parse(data['text'])
  query_string = neo4j_client.generate_create_query_for_sentences(sentences)
  neo4j_client.clear
  neo4j_client.execute(query_string)

  matches = PointsExtraction.matches_for_verbs(neo4j_client, frames, frame_queries)
  PointsExtraction.points_for_matches(neo4j_client, matches, data['keys'])
    .uniq
    .sort_by(&:size)
    .to_json
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end
