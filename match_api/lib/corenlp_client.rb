class CoreNlpClient
  def initialize(host)
    #params = URI.encode('properties={"annotators": "lemma,parse,depparse", "parse.flags": " -makeCopulaHead"}')
    params = URI.encode('properties={"annotators": "lemma,parse,depparse"}')

    @uri = URI(host + "/?" + params)
    @http_client = Net::HTTP.new(@uri.host, @uri.port)
  end

  def request_parse(sentence)
    req = Net::HTTP::Post.new(@uri)
    req.body = sentence
    response = JSON.parse(@http_client.request(req).body)['sentences'].first

    [response['tokens'], response['collapsed-ccprocessed-dependencies']]
  end

  def write_sentence_fixture(sentence)
    parse = request_parse(sentence)
    expected = Graph.new(*parse).nodes.map do |node|
      node.point_strings
    end.flatten

    filename = sentence.downcase.gsub(/\s+/,'-').gsub(/[^-\w]/, '') + '.json'
    File.open('test/fixtures/' + filename, 'w') do |f|
      f.write({ parse: parse, expected: expected }.to_json)
    end
  end
end
