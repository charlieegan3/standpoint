require 'summarize'
require 'ots'

COUNT = 5

text = File.open("text.txt").read

sentence_count = text.scan(/\. /).size
ratio = ((COUNT.to_f / sentence_count) * 100).ceil

summary = text.summarize(ratio: ratio * 2)
summary.split(".").take(COUNT).each do |s|
  puts "  * #{s.strip}."
end
puts

parsed = OTS.parse(text)
parsed.summarize(sentences: COUNT).sort_by { |e| e[:score] }.reverse.each do |s|
  puts "  * #{s[:sentence].strip}"
end
