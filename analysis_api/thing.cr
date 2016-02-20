require "http/client"
require "json"

response = HTTP::Client.get "http://comment_store:3000/comments/1.json?flat=1"
data = JSON.parse(response.body)
puts data

