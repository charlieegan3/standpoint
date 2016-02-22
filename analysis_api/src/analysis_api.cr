require "http/client"
require "json"

require "./analysis_api/*"

module AnalysisApi
  def self.run
    response = HTTP::Client.get "http://comment_store:3000/comments/754.json?flat=1"
    blob = JSON.parse(response.body).as_a
      .map { |c| (c as Hash)["body"] as String }[1..-1]
      .map { |c| c.split("\n") }
      .flatten
      .select { |c| /^[A-Za-z]/.match(c) && c.split(" ").size > 4 }
      .map { |c| c[-1] == '.' ? c : c + "." }
      .join(" ")

    response = HTTP::Client.post("http://corenlp_server:9000/?properties=%7B%22annotators%22%3A%20%22tokenize%2Cssplit%22%7D", body: blob)
    clean = JSON.parse(response.body.gsub(/[^\w\{\}\]\[,:\s"\\']/, ""))
      .as_h["sentences"] as Array
    sentences = clean.map { |s| ((s as Hash)["tokens"] as Array).map { |t| (t as Hash)["word"] }.join(" ").gsub(/\s\W/) { |m| m[1] }.gsub(/LRB|RRB/, "") }
    sentences.reject! { |s| s.size < 20 }

    topic_query = { text: blob, topic_count: 8, top_word_count: 8 }.to_json
    response = HTTP::Client.post("http://topic_api:4567/", body: topic_query)
    topics = JSON.parse(response.body)["topics"].as_a
    puts topics

    sentences.select! { |s| topics.map { |t| s.downcase.includes? (t as String) }.includes? true }

    sentences.each do |sentence|
      query = { sentence: sentence }.to_json
      response = HTTP::Client.post("http://points_api:4567/", body: query)
      next unless response.status_code == 200
      data = JSON.parse(response.body).as_a
      data.each do |point|
        next if (point as Array).size < 2
        (point as Array).each do |c|
          print (((((c as Hash)["match"] as Hash)["node"]  as Hash)["node"]) as Hash)["word"]
          print " "
        end
        print "\n"
      end
    end
  end
end

AnalysisApi.run
