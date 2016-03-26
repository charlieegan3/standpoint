require 'pry'
require 'erb'

summaries = {}
Dir.glob('summaries/*') do |file|
  name = file.split(/\W/)[1]
  contents = File.open(file).read
  summaries[name] = contents
end

pairs = [%w(abortion creation), %w(creation abortion), %w(god guns),
  %w(guns god), %w(gay_rights healthcare), %w(healthcare gay_rights)]

pairs.each_with_index do |pair, index|
  debate1, debate2 = pair
  erb = ERB.new(File.open("survey.html.erb").read, 0, '>')
  File.open("#{index}.html", "w") { |file| file.write(erb.result(binding)) }
end
