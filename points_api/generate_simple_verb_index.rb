require 'json'

verb_index = Array.new

JSON.parse(File.open("verbs.json").read).each do |verb, frames|
  verb_index << {
    verb: verb,
    frame_patterns: frames.map do |frame|
      frame["syntax"].map { |component| component["name"] }.join(" ")
    end.uniq
  }
end

puts verb_index.to_json
