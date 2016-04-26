# process_extract_comparison.rb
#
# This is a general purpose script to process the results from Study 2.
# It prints the results in a variety of formats.

require 'pry'
require 'csv'

responses = []
Dir.glob('./extract_comparison/ext*') do |path|
  rows = []
  CSV.foreach(path) do |row|
    rows << row
  end
  headers, rows = rows[0], rows[1..-1]
  responses += rows.map { |r| Hash[*headers.zip(r).flatten] }
end

puts "Unique Workers: #{responses.map { |x| x["WorkerId"] }.uniq.size}"
answers = []

bigram_v_rand_answers = []
comments = []

responses.each_with_index do |r, i|
  r.select { |k, _| k.include? "Answer" }.sort_by { |_, v| v.length }.each do |q, a|
    topic, id =  q.gsub("Answer.", "").split("-")
    if id.match(/set[123]extract[0-9]+/)
      a = a.gsub(",", ";").gsub(/\s+/, " ").to_i
      answers << [topic + id, a, i]
    elsif a.match(/^\w+\-\w+$|^same$/)
      bigram_v_rand_answers << a
    else
      last_response = r.select { |k, v| k.include? id }.first.last
      comments << { topic: topic, comment: a, last_response: last_response }
    end
  end
end

topic_sets = []
Dir.glob('./extracts/ext*') do |path|
  contents = File.open(path).read
  sets = contents.split("------").map { |g| g.split("\n").reject { |l| l == "" } }.map do |g|
    extracts = g[1..-2]
    extracts[extracts.index(g[-1][2..-1])] = "(SELECTED) " + g[-1][2..-1]
    extracts
  end
  topic = path.match(/\/extracts_(\w+)\.txt/)[1]
  topic_sets << [topic, sets]
end

scored_sentences = []
topic_sets.each do |topic, sets|
  sets.each_with_index do |set, set_index|
    set.each_with_index do |extract, extract_index|
      key = "#{topic}set#{set_index + 1}extract#{extract_index + 1}"
      scores = answers.select { |k, _| k == key }.map(&:last)
      scores = answers.select { |k, _| k == key }.map { |_, v, _| v }
      score = (scores.reduce(:+).to_f / scores.size)
      scored_sentences << [extract, score]
    end
  end
end

less_than = 0
more_than = 0
answers.group_by(&:last).each do |k,v|
  average = v.map { |a, s, _| s }.reduce(:+).to_f / v.size
  topic = v.first.first.split("set").first
  topic_sets.select { |k, v| k == topic }.each do |k, sets|
    sets.each_with_index do |set, index|
      index += 1
      ans = Hash[*v.select { |k, _, _| k.include? "set#{index}" }.map { |k, v| [k.scan(/[0-9]+$/).first.to_i, v] }.flatten]
      selected_index = set.index(set.select { |v| v.include? "SELECTED" }.first) + 1
      score_for_selected = ans[selected_index]
      score_for_selected < average ? less_than += 1 : more_than += 1
    end
  end
end

puts "Better than avg: #{more_than.to_f/(more_than+less_than)}"

answers.map! { |x, y, _| [x, y] }

print "All Extracts: "
p mean = scored_sentences.map(&:last).reduce(:+) / scored_sentences.size

print "Selected Extracts: "
selected = scored_sentences.select { |s| s.first.include? "SELECTED" }
puts selected_mean = selected.map(&:last).reduce(:+) / selected.size

print "Other Extracts: "
rejected = scored_sentences - selected
puts rejected_mean = rejected.map(&:last).reduce(:+) / rejected.size

selected.sort_by(&:last).reverse.map { |e, s| puts "#{s.round(3)} - #{e}" }
rejected.sort_by(&:last).reverse.map { |e, s| puts "#{s.round(3)} - #{e}" }

puts "\nComments\n"
comments.each do |comment|
  puts [
    comment[:topic].upcase,
    "A was bigram, B was random",
    "rating given: " + comment[:last_response].gsub(/^layout/, "bigram_layout")
  ].join(", ")
  text = comment[:comment]
  text.gsub!(/(^|\W)A\W/, " [BIGRAM] ")
  text.gsub!(/(^|\W)B\W/, " [RANDOM] ")
  puts text.strip
  puts "-"*100
end

puts "\nRatings:"
["layout-much_better", "layout-better", "same", "random_layout-better", "random_layout-much_better"].each do |a|
  puts ["bigram_vs_random", "overall", a, bigram_v_rand_answers.count(a).to_i].join(",")
end
