require 'sinatra'
require 'tree'
require 'descriptive_statistics'
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
    .map { |t|
      {
        lemma: t['lemma'],
        word: t['word'],
        text: t['originalText'],
      }
    }
    .map { |v| v.merge({ frames: [VERBS[v[:lemma]], VERBS[v[:word]]].flatten.compact }) }
    .compact
    .reject { |v| v[:frames].empty? }
end

post '/' do
  req =  Net::HTTP::Post.new(uri)
  req.body = JSON.parse(request.body.read)['sentence']
  sentence = JSON.parse(http.request(req).body)['sentences'].first

  raw_parse = sentence['parse']
  parse = Parser.parse_tree(raw_parse)
  tree = Parser.build_tree(parse)

  matches = []
  (verbs = verbs_for_tokens(sentence['tokens'])).each do |verb|
    verb[:frames].each do |frame|
      matches += tree.scan(Pattern.new(frame['pattern']), verb)
    end
  end

  matches = matches.group_by { |m| m[:string] }
    .map { |k, v|
      {
        string: k,
        score: v.first[:score],
        verb: v.first[:verb],
        matched_frames: v.map { |s| s[:frame] },
        tree: v.first[:match],
      }
    }

  scores = matches.map { |m| m[:score] }
  matches.each { |m| m[:score] = scores.percentile_rank(m[:score]) }
  matches = matches.sort_by { |m| m[:score] }.reverse

  {
    verbs: verbs,
    matches: matches,
    parse: parse,
    raw_parse: raw_parse,
    tree: tree,
  }.to_json
end
