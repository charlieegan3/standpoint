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

answers = []

bigram_v_rand_answers = []
comments = []

responses.each do |r|
  r.select { |k, _| k.include? "Answer" }.sort_by { |_, v| v.length }.each do |q, a|
    topic, id =  q.gsub("Answer.", "").split("-")
    if id.match(/set[123]extract[0-9]+/)
      a = a.gsub(",", ";").gsub(/\s+/, " ").to_i
      answers << [topic + id, a]
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
      score = (scores.reduce(:+).to_f / scores.size)
      scored_sentences << [extract, score]
    end
  end
end


print "All Extracts: "
p mean = scored_sentences.map(&:last).reduce(:+) / scored_sentences.size

print "Selected Extracts: "
selected = scored_sentences.select { |s| s.first.include? "SELECTED" }
puts selected_mean = selected.map(&:last).reduce(:+) / selected.size

print "Other Extracts: "
rejected = scored_sentences - selected
puts rejected_mean = rejected.map(&:last).reduce(:+) / rejected.size

selected.sort_by(&:last).reverse.map { |e, s| puts "#{s.round(1)} - #{e}" }
rejected.sort_by(&:last).reverse.map { |e, s| puts "#{s.round(1)} - #{e}" }

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
bigram_v_rand_answers.uniq.sort.each do |a|
  print a + ": "
  puts (bigram_v_rand_answers.count(a).to_f * 100 / bigram_v_rand_answers.size).round(2).to_s + "%"
end
