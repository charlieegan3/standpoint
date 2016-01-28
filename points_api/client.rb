class CoreNlpClient
  def initialize(host)
    @host = host
  end

  def points_for_sentences(text, pattern)
    sentences = Hash.new

    get_points(text, pattern)["sentences"].each_with_index do |points, index|
      sentences[index] = Sentence.new

      points.delete("length")
      points.each do |p|
        p = p.last
        p.delete_if { |k,_| ["text", "begin", "end"].include? k }

        point = Point.new(sentences[index])

        p.sort_by {|_, value| value["end"]}.map do |key, value|
          point.add_component(key, value["end"], value["text"])
        end
        sentences[index].points << point
      end
    end

    get_sentences(text)["sentences"].map do |s|
      sentences[s["index"]].words = Hash[s["tokens"].map { |t| [t["index"], t["word"]] }]
    end

    sentences
  end

  private

  def get_sentences(text)
    params = 'properties={"annotators": "tokenize,ssplit"}'
    request("", params, text)
  end

  def get_points(text, pattern)
    params = "pattern=" + pattern
    request("semgrex", params, text)
  end

  def request(endpoint, params, body)
    uri = URI(@host + endpoint + "?" + URI.encode(params))
    http = Net::HTTP.new(uri.host, uri.port)
    req =  Net::HTTP::Post.new(uri)
    req.body = body
    JSON.parse(http.request(req).body)
  end
end
