require "json"
require 'net/http'

unless ARGV[0]
  puts "missing corpus"
  exit
end

path = "debates/#{ARGV[0]}/*"
posts = []
Dir.glob(path) do |f|
  next unless f.include? "json"
  post = JSON.parse(File.open(f).read)
  posts << post if post["content"].length > 30
end

topic_text = posts.map{ |p| p["content"] }.join("\n").gsub(/[^\w']/, " ").gsub(/\s+/, " ").downcase[0..60000]

uri = URI('http://topic_api:4567/')
http = Net::HTTP.new(uri.host, uri.port)
topic_query = { text: topic_text, topic_count: 8, top_word_count: 8 }.to_json

req = Net::HTTP::Post.new(uri)
req.body = topic_query
topics = JSON.parse(http.request(req).body)["topics"]

out_file = File.open("#{ARGV[0]}_points.txt", "w")

out_file.write("#{posts.size}\n")
uri = URI('http://points_api:4567/')
http = Net::HTTP.new(uri.host, uri.port)
posts.each_with_index do |post, index|
  query = { text: post["content"], topics: topics, keys: %w(string pattern) }.to_json
  req = Net::HTTP::Post.new(uri)
  req.body = query
  data = JSON.parse(http.request(req).body)
  data.map { |p| out_file.write("#{p.merge(post).to_json},\n") }
end
