require 'sinatra'
require 'tree'
require 'pry'

require 'json'
require 'net/http'

require_relative './lib/pattern.rb'
require_relative './lib/parser.rb'
require_relative './lib/node.rb'

VERBS = JSON.parse(File.open('verbs.json', 'r').read)

set :port, ENV['PORT']
set :bind, '0.0.0.0'

params = 'properties={"annotators": "pos,parse,lemma"}'
uri = URI("http://corenlp_server:#{ENV['CNLP_PORT']}/?" + URI.encode(params))

http = Net::HTTP.new(uri.host, uri.port)

def verbs_for_tokens(tokens)
  tokens.select { |t| t['pos'].include?("VB") }
    .map { |t| [t['lemma'], t['word'], t['originalText']] }
    .flatten
    .uniq
    .map { |v| { verb: v, frames: VERBS[v] } if !VERBS[v].nil? }
    .compact
end

post '/' do
  req =  Net::HTTP::Post.new(uri)
  req.body = JSON.parse(request.body.read)['sentence']
  sentence = JSON.parse(http.request(req).body)['sentences'].first

  raw_parse = sentence['parse']
  parse = Parser.parse_tree(raw_parse)
  base_tree = Parser.build_tree(parse)

  matches = []
  (verbs = verbs_for_tokens(sentence['tokens'])).each do |verb|
    next unless verb[:frames]
    verb[:frames].each do |frame|
      round_tree = base_tree.dup

      if (result = round_tree.scan(Pattern.new(frame['pattern'])))
        matches << result
      end
    end
  end

  {
    verbs: verbs,
    matches: matches,
    parse: parse,
    tree: base_tree,
  }.to_json
end
