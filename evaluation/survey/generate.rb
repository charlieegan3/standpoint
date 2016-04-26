# generate.rb
#
# This is a script used in generating the evaluation questionnaires

require 'pry'
require 'erb'

summaries = {}
Dir.glob('summaries/*') do |file|
  name = file.split(/\W/)[1]
  contents = File.open(file).read
  summaries[name] = contents
end

sets = [%w(abortion creation god), %w(creation abortion guns), %w(god guns gay_rights),
  %w(guns god healthcare), %w(gay_rights healthcare abortion), %w(healthcare gay_rights creation)]

sets.each_with_index do |set, index|
  debate1, debate2, debate3 = set
  erb = ERB.new(File.open("survey.html.erb").read, 0, '>')
  File.open("#{index+1}.html", "w") { |file| file.write(erb.result(binding)) }
end
