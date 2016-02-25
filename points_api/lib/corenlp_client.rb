class CoreNlpClient
  def initialize(host)
    #params = URI.encode('properties={"annotators": "lemma,parse,depparse", "parse.flags": " -makeCopulaHead"}')
    params = URI.encode('properties={"annotators": "lemma,tokenize,ssplit,depparse"}')

    @uri = URI(host + "/?" + params)
    @http_client = Net::HTTP.new(@uri.host, @uri.port)
  end

  def request_parse(text)
    req = Net::HTTP::Post.new(@uri)
    req.body = text
    JSON.parse(@http_client.request(req).body)['sentences'].map do |sentence|
      [sentence['tokens'], sentence['collapsed-ccprocessed-dependencies']]
    end
  end
end
