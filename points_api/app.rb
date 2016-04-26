# app.rb
#
# This file implements the core of the points extraction service. It defines
# a root route that that accepts requests for points analysis. It splits the
# text into chunks and extracts sentences before triggering the points analysis.

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
require './lib/utils'

set :port, ENV['PORT']
set :bind, '0.0.0.0'
set :public_folder, 'static'

# configure the clients for communicating with the other services
corenlp_client = CoreNlpClient.new("http://corenlp_server:#{ENV['CNLP_PORT']}")
neo4j_client = Neo4jClient.new("http://neo4j:7474")

frames = JSON.parse(File.open('verbs.json', 'r').read)
frame_queries = Hash[*Dir.glob('frame_queries/*.cql').map do |path|
  [path.scan(/\/((\w|-)+)\./)[0][0].humanize.upcase.gsub('-COPULA', '-cop'),
    File.open(path, 'r').read]
end.flatten]

# requests for points analysis are handled here
post '/' do
  data = JSON.parse(request.body.read)

  points = []
  # text is split into smaller sections, CoreNLP has a 100000 char limit
  Utils.chunk_text(35000, Utils.clean_text(data["text"])).each do |text|
    # remove all the content from the database
    neo4j_client.clear
    # get parses for the sentences
    sentences = corenlp_client.request_parse(text)
    # select sentences with topic words
    sentences.select! { |s| Utils.sentence_contains_topic(s, data['topics']) }
    next if sentences.empty?
    begin
      puts sentences.size
      sentences.each_slice(5).each do |group|
        # save the sentences to the database
        query_string = neo4j_client.generate_create_query_for_sentences(group)
        neo4j_client.execute(query_string)
      end
      # find valid points
      matches = PointsExtraction.matches_for_verbs(neo4j_client, frames, frame_queries)
      # find the extracts for the valid points
      points += PointsExtraction.points_for_matches(neo4j_client, matches, data['topics'], data['keys'])
        .uniq
        .sort_by(&:size)
    rescue Exception => ex
      puts ex
      return points.to_json
    end
  end

  points.to_json
end
