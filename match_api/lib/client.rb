class Client
  def initialize(host)
    params = URI.encode('properties={"annotators": "depparse"}')

    @uri = URI(host + "/?" + params)
    @http_client = Net::HTTP.new(@uri.host, @uri.port)
  end

  def request_parse(sentence)
    req = Net::HTTP::Post.new(@uri)
    req.body = sentence
    response = JSON.parse(@http_client.request(req).body)['sentences'].first

    [response['tokens'], response['basic-dependencies']]
  end
end
