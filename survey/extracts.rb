require 'pry'
require 'erb'

summaries = {}
Dir.glob('summaries/*') do |file|
  name = file.split(/\W/)[1]
  contents = File.open(file).read
  summaries[name] = contents
end

topics = %w(abortion creation guns god gay_rights healthcare)




groups = topics.map do |t|
  sets = File.open("extracts_#{t}.txt").read.split("------")
  sets.map { |s| s.split("\n").select { |l| l.length > 0 && l[0].match(/\w/) }.shuffle }
end

index = 0
topics.zip(groups).each do |topic, sets|
  erb = ERB.new(File.open("survey_extract.html.erb").read, 0, '>')
  File.open("#{topic}.html", "w") { |file| file.write(erb.result(binding)) }
  index += 1
end
