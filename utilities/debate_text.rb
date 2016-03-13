require 'json'
text = Dir.glob("../analysis_api/debates/#{ARGV[0]}/*.json").to_a.map do |f|
  JSON.parse(File.open(f).read)["content"]
end.take(ARGV[1].to_i).join(" ")

puts text
