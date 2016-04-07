require 'pry'
require 'erb'

summaries = {}
Dir.glob('summaries/*') do |file|
  name = file.split(/\W/)[1]
  contents = File.open(file).read
  summaries[name] = contents
end

topics = %w(abortion creation guns god gay_rights healthcare)
contents = File.open('extracts.txt').read
groups = contents.split("------").map { |e| e.split("\n").select { |l| l.match(/^\w/) } }

index = 0
topics.zip(groups.reject(&:empty?)).each do |topic, extracts|
  erb = ERB.new(File.open("survey_extract.html.erb").read, 0, '>')
  File.open("#{topic}.html", "w") { |file| file.write(erb.result(binding)) }
  index += 1
end
