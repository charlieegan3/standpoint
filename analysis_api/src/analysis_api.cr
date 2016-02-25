require "http/client"
require "json"

require "./analysis_api/*"

module AnalysisApi
  def self.run
    path = "debates/abortion"
    blob = [] of String
    Dir.new(path).each do |f|
      next unless f.includes? "post"
      blob << File.read_lines(path+"/"+f).join("\n")
    end

    sentences = [] of String
    blob.in_groups_of(50).each do |group|
      group = group.join("\n")
      response = HTTP::Client.post("http://corenlp_server:9000/?properties=%7B%22annotators%22%3A%20%22tokenize%2Cssplit%22%7D", body: group)
      clean = JSON.parse(response.body.gsub(/[^\w\{\}\]\[,:\s"\\']/, ""))
        .as_h["sentences"] as Array
      sentences += clean.map { |s| ((s as Hash)["tokens"] as Array).map { |t| (t as Hash)["word"] }.join(" ").gsub(/\s\W/) { |m| m[1] }.gsub(/LRB|RRB/, "") }
    end
    sentences.reject! { |s| s.size < 20 }

    string = sentences[0..sentences.size/20].join("\n")

    topic_query = { text: string, topic_count: 8, top_word_count: 8 }.to_json
    response = HTTP::Client.post("http://topic_api:4567/", body: topic_query)
    topics = JSON.parse(response.body)["topics"].as_a
    puts topics

    sentences.select! { |s| topics.map { |t| s.downcase.includes? (t as String) }.includes? true }

    sentences.each do |sentence|
      query = { sentence: sentence }.to_json
      begin
        response = HTTP::Client.post("http://points_api:4567/", body: query)
        next unless response.status_code == 200
        data = JSON.parse(response.body).as_a
      rescue ex
        puts ex.message
        sleep 5
        next
      end
      data.each do |point|
        nodes = ((point as Hash)["nodes"] as Array)
        next if nodes.size < 2
        string = (point as Hash)["string"]
        point = nodes.map do |c|
          [
            (((((c as Hash)["match"] as Hash)["node"]  as Hash)["node"]) as Hash)["lemma"],
            (((c as Hash)["match"] as Hash)["tag"] as String)
          ].join(".")
        end
        point = { point: point, string: string }
        puts point.to_json
      end
    end
  end
end

AnalysisApi.run
