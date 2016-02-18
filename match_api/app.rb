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
  [path.scan(/\/((\w|-)+)\./)[0][0].humanize.upcase.gsub('-COPULA', '-cop'),
    File.open(path, 'r').read]
end.flatten]
copulae = %w(act appear be become come end get go grow fall feel keep look prove remain run seem smell sound stay taste turn wax)

post '/' do
  sentence = JSON.parse(request.body.read)['sentence']
  tokens, dependencies = corenlp_client.request_parse(sentence)
  neo4j_client.clear
  neo4j_client.create(tokens, dependencies)

  points = []
  neo4j_client.verbs.each do |verb|
    next if verbs[verb.lemma].nil?

    frames = verbs[verb.lemma].map { |f| Frame.new(f, verb.lemma) }
    if copulae.include? verb.lemma
      frames += Frame.copula_frames(verb.lemma)
    end

    frames.group_by { |f| [f.pos_pattern_string, f.is_copula?] }.each do |pattern, frames|
      query_name = pattern.last ? pattern.first + '-cop' : pattern.first
      query = frame_queries[query_name]
      next unless query
      match = neo4j_client.query(verb, query)
      unless match.empty?
        frames.each do |frame|
          points << match.zip(frame.components).map { |m, c| { match: m, component: c } }
        end
      end
    end
  end
  points.uniq.sort_by(&:size).to_json
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end
