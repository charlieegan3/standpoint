require 'sinatra'
require 'net/http'
require 'json'

require_relative 'sentence'
require_relative 'point'
require_relative 'client'

set :port, ENV['PORT']
set :bind, '0.0.0.0'

client = CoreNlpClient.new("http://corenlp_server:#{ENV['CNLP_PORT']}/")

get "/" do
  "Post to this route with a JSON payload. (text, pattern)"
end

post '/' do
  payload = JSON.parse(request.body.read)
  client.points_for_sentences(
    payload["text"], payload["pattern"]
  ).map do |index, sentence|
    sentence.points.map { |point| point.string }
  end.to_json
end
