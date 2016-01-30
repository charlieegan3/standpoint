require 'nokogiri'
require 'pp'
require 'json'

verbs = {}
concepts = {}

Dir["./new_vn/*.xml"].each do |f|
  concept = f.gsub('./new_vn/', '').match(/\w+/).to_s

  doc = Nokogiri::XML(File.open(f, 'r').read)

  frames = doc.css('FRAME').map do |fr|
    {
      pattern: fr.at_css('DESCRIPTION')['primary'],
      examples: fr.css('EXAMPLE').map(&:text)
    }
  end

  members = doc.css('MEMBER').map do |mem|
    verbs[mem['name']] = frames
  end

  concepts[concept] = { frames: frames, members: doc.css('MEMBER').map { |m| m['name'] } }
end


File.open('verbs.json', 'w') { |f| f.write(verbs.to_json) }
File.open('concepts.json', 'w') { |f| f.write(concepts.to_json) }
