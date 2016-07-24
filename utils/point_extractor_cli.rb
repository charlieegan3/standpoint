require 'open-uri'
require "net/http"
require "json"

if ARGV.size != 2
  puts "Expected: ruby point_extractor_cli.rb {docker_host} {comment_file}"
  puts "E.g.      ruby point_extractor_cli.rb http://local.docker:3456 comments.txt"
  puts "\nFinding the docker machine IP/hostname depends on your docker setup. The point_extractor will run on 3456 by default."
  puts "Comment file should have one comment per line."
  exit
end

host = ARGV[0]
comment_file = ARGV[1]

lines = []
begin
  lines = File.open(comment_file).readlines.map(&:chomp)
rescue Exception => e
  puts e.message
  puts "Failed to open comments file"
end

unless `docker ps`.include?("point_extractor")
  `docker-compose up -d point_extractor` rescue puts "failed to start point_extractor"
end

points = []

uri = URI(host + "/points")
http = Net::HTTP.new(uri.host, uri.port)
lines.each do |line|
  req = Net::HTTP::Post.new(uri)
  req.body = line
  resp = http.request(req)
  if http.request(req).message == "OK"
    JSON.parse(resp.body).each do |point|
      puts point
      points << point
    end
  else
    puts "Failed to get points for: #{line}"
    puts resp.message
  end
end

File.open("points.json", "w").write(JSON.pretty_generate(points))
puts "points.json saved"
