# corenlp_client
#
# This is a wrapper used in requesting dependency parse information from
# the CoreNLP service.

class CoreNlpClient
  def initialize(host)
    #params = URI.encode('properties={"annotators": "lemma,parse,depparse", "parse.flags": " -makeCopulaHead"}')
    params = URI.encode('properties={"annotators": "lemma,tokenize,ssplit,depparse"}')

    @uri = host + "/?" + params
    _, host, port = host.split(/\W+/)
    @http_client = Net::HTTP.new(host, port)
  end

  def request_parse(text)
    req = Net::HTTP::Post.new(@uri)
    req.body = text
    JSON.parse(@http_client.request(req).body)['sentences'].map do |sentence|
      [sentence['tokens'], sentence['collapsed-ccprocessed-dependencies']]
    end
  end
end
