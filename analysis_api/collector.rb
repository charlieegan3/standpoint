require "json"
require 'net/http'

path = "debates/abortion/*"
posts = []
Dir.glob(path) do |f|
  next unless f.include? "json"
  posts << JSON.parse(File.open(f).read)
end

topic_text = posts.map{ |p| p["content"] }.join("\n").gsub(/[^\w']/, " ").gsub(/\s+/, " ").downcase[0..60000]

uri = URI('http://topic_api:4567/')
http = Net::HTTP.new(uri.host, uri.port)
topic_query = { text: topic_text, topic_count: 8, top_word_count: 8 }.to_json

req = Net::HTTP::Post.new(uri)
req.body = topic_query
topics = JSON.parse(http.request(req).body)["topics"]

puts posts.size
uri = URI('http://points_api:4567/')
http = Net::HTTP.new(uri.host, uri.port)
posts.each_with_index do |post, index|
  query = { text: post["content"], topics: topics, keys: %w(string pattern) }.to_json
  begin
    req = Net::HTTP::Post.new(uri)
    req.body = query
    data = JSON.parse(http.request(req).body)
  rescue Exception => e
    puts e.message
    next
  end
  data.map { |p| puts p.merge(post).to_json }
end
