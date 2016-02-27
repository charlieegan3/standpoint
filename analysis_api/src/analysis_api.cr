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

    blob = blob.join(" ")

    topic_text = blob.gsub(/[^\w']/, " ").gsub(/\s+/, " ").downcase[0..60000]

    topic_query = { text: topic_text, topic_count: 8, top_word_count: 8 }.to_json
    response = HTTP::Client.post("http://topic_api:4567/", body: topic_query)
    topics = JSON.parse(response.body)["topics"].as_a
    puts topics

    count = blob.split("\n").size
    blob.split("\n").each_with_index do |post, index|
      query = { text: post, topics: topics, keys: %w(string pattern) }.to_json
      begin
        response = HTTP::Client.post("http://points_api:4567/", body: query)
        next unless response.status_code == 200
        data = JSON.parse(response.body).as_a
      rescue ex
        puts ex.message
        sleep 5
        next
      end
      data.map { |p| puts "#{(index.to_f/count) * 100} #{p.to_json}" }
    end
  end
end

AnalysisApi.run
