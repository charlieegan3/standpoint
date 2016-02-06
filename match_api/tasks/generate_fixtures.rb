require 'json'
require 'net/http'
require 'pry'

require_relative '../lib/client'
require_relative '../lib/graph'
require_relative '../lib/node'
require_relative '../lib/edge'

[
  "They went to paris and berlin",
  "They went to Paris from Berlin",
  "They went to Paris and then to Berlin",
  "They went to the shop and bought milk",
  "The film was crappy",
  "The man was a builder",
].each do |sentence|
  client = Client.new("http://corenlp_server:#{ENV['CNLP_PORT']}")
  client.write_sentence_fixture(sentence, [1,2,3])
end
