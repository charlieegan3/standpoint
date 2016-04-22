require 'pry'
require 'csv'

ab_index = {
  ["abortion", ["layout", "formatted"]] => ["B", "A"],
  ["abortion", ["layout", "stock"]] => ["A", "B"],
  ["abortion", ["plain", "stock"]] => ["A", "B"],
  ["creation", ["layout", "formatted"]] => ["A", "B"],
  ["creation", ["layout", "stock"]] => ["B", "A"],
  ["creation", ["plain", "stock"]] => ["B", "A"],
  ["god", ["layout", "formatted"]] => ["B", "A"],
  ["god", ["layout", "stock"]] => ["A", "B"],
  ["god", ["plain", "stock"]] => ["A", "B"],
  ["guns", ["layout", "formatted"]] => ["A", "B"],
  ["guns", ["layout", "stock"]] => ["B", "A"],
  ["guns", ["plain", "stock"]] => ["B", "A"],
  ["gay_rights", ["layout", "formatted"]] => ["B", "A"],
  ["gay_rights", ["layout", "stock"]] => ["A", "B"],
  ["gay_rights", ["plain", "stock"]] => ["A", "B"],
  ["healthcare", ["layout", "formatted"]] => ["A", "B"],
  ["healthcare", ["layout", "stock"]] => ["B", "A"],
  ["healthcare", ["plain", "stock"]] => ["B", "A"]
}

responses = []
Dir.glob('./summary_comparison/sum*') do |path|
  rows = []
  CSV.foreach(path) do |row|
    rows << row
  end
  headers, rows = rows[0], rows[1..-1]
  responses += rows.map { |r| Hash[*headers.zip(r).flatten] }
end

puts "Unique Workers: #{responses.map { |x| x["WorkerId"] }.uniq.size}"

answers = []
comments = []
responses.each do |r|
  r.select { |k, _| k.include? "Answer" }.sort_by { |_, v| v.size }.each do |q, a|
    topic, comparing, type =  q.gsub("Answer.", "").split("-")
    a = a.gsub(",", ";").gsub(/\s+/, " ")
    if a.match(/^\w+\-\w+$|^same$/)
      answers << [topic, *comparing.split("_v_"), type, a]
      last = answers.last
    else
      last_response = r.select { |k, v| k.include?(comparing + "-overall") }.first.last
      orientation = ab_index[[topic, comparing.split("_v_")]]
      translation = Hash[*orientation.zip(comparing.split("_v_")).flatten]
      comments << { topic: topic, translation: translation, comment: a, last_response: last_response }
    end
  end
end

[["plain", "stock"], ["layout", "stock"], ["layout", "formatted"]].each do |pair|
  ["overall", "content", "punctuation", "readability", "organization"].each do |factor|
    counts = answers.map { |a| a[1..-1] }
      .select { |r| r[0..1] == pair && r[2] == factor}
      .group_by { |x| x.last }
      .map { |k, v| [k, v.size] }
      .sort_by { |k, v| v }
    next if counts.empty?
    sum = counts.map(&:last).reduce(:+)
    counts = Hash[*counts.flatten]
    [pair.first+"-much_better", pair.first+"-better", "same", pair.last+"-better", pair.last+"-much_better"].each do |answer|
      puts [pair.join("_vs_"), factor, answer, counts[answer].to_i].join(",")
    end
  end
end

comments.group_by { |c| c[:translation].values.sort }.each do |k, comments|
  puts k.join(" vs. ")
  comments.each do |comment|
    puts [
      comment[:topic].upcase,
      comment[:translation].map { |k, v| "#{v} was #{k}" }.join(", "),
      "rating given: " + comment[:last_response]
    ].join(", ")
    text = comment[:comment]
    comment[:translation].each do |from, to|
      text.gsub!(/(^|\W)#{from}\W/, " [#{to.upcase}] ")
    end
    puts text.strip
    puts "-"*75
  end
  puts ["*"*100, "*"*100, "\n"].join("\n")
end
