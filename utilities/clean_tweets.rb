require 'pry'
require 'json'

folder_paths = %w(yes_day no_day yes_after no_after).map { |f| "../analysis_api/tweets/#{f}/*" }

folder_paths.each do |path|
  puts path
  Dir.glob(path).to_a.each do |file, index|
    content = File.open(file).read.chars.select(&:valid_encoding?).join
    content.gsub!(/\s+/, " ")
    id = file.split("/").last.gsub(".txt", "").gsub(/\W/, "").strip

    File.open("#{file.gsub(".txt", "")}.json", "w").write({ content: content, post: id }.to_json)
  end
end
