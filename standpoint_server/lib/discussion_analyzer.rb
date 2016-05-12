require "json"
require "net/http"

require_relative '../config/environment'

class DiscussionAnalyzer
  def perform(discussion)
    points = get_points(discussion.comments, get_topics(discussion.topic_text))
  end

  handle_asynchronously :perform

  private
  def get_topics(text)
    topic_query = { text: text, topic_count: 8, top_word_count: 8 }.to_json

    uri = URI('http://topic_api:4567/')
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri)
    req.body = topic_query

    JSON.parse(http.request(req).body)["topics"]
  end

  def get_points(comments, topics)
    uri = URI('http://points_api:4567/')
    http = Net::HTTP.new(uri.host, uri.port)
    puts comments.size
    count = 0
    comments.each do |c|
      puts count += 1
      query = {
        text: c.text,
        topics: topics,
        keys: %w(string pattern)
      }.to_json
      req = Net::HTTP::Post.new(uri)
      req.body = query
      JSON.parse(http.request(req).body).each do |point|
        Point.create(
          comment: c, extract: point["string"], pattern: point["pattern"])
      end
    end
  end
end
