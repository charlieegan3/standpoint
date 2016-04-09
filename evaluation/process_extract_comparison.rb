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
responses.each do |r|
  r.select { |k, _| k.include? "Answer" }.each do |q, a|
    topic, id =  q.gsub("Answer.", "").split("-")
    next unless id.match(/set[123]extract[0-9]+/)
    a = a.gsub(",", ";").gsub(/\s+/, " ").to_i
    answers << [topic + id, a]
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
