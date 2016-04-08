require 'pry'
require 'csv'

responses = []
Dir.glob('./summary_comparison/sum*') do |path|
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
    topic, comparing, type =  q.gsub("Answer.", "").split("-")
    a = a.gsub(",", ";").gsub(/\s+/, " ")
    next unless a.match(/^\w+\-\w+$|^same$/)
    answers << [topic, *comparing.split("_v_"), type, a]
  end
end

[["plain", "stock"], ["layout", "stock"], ["layout", "formatted"]].each do |pair|
  puts pair.join(" vs ").upcase
  ["overall", "content", "punctuation", "readability", "organization"].each do |topic|
    counts = answers.map { |a| a[1..-1] }
      .select { |r| r[0..1] == pair && r[2] == topic }
      .group_by { |x| x.last }
      .map { |k, v| [k, v.size] }
      .sort_by { |k, v| v }
    next if counts.empty?
    puts "  " + topic
    sum = counts.map(&:last).reduce(:+)
    counts.each do  |k, v|
      puts "    #{k}: #{((v.to_f/sum) * 100).round(1)}%"
    end
  end
  puts "-" * 50
end
