require 'json'
require 'nokogiri'
require 'pry'

verbs = Hash.new([])

Dir.glob('verb_frames/*.xml') do |path|
  doc = Nokogiri::XML(File.open(path).read)
  members = doc.css('MEMBERS MEMBER').map { |e| e['name'] }

  frames = doc.css('FRAMES FRAME').map do |frame|
    examples = frame.css('EXAMPLE').map(&:text)
    syntax = frame.css('SYNTAX > *').map do |component|
      { name: component.name, value: component['value'],
        restrictions: component.css('SYNRESTR').map{ |s| { value: s['value'], type: s['type'] } }}
    end
    semantics = frame.css('SEMANTICS > *').map do |predicate|
      {
        value: predicate['value'],
        args: predicate.css('ARG').map { |a| { type: a['type'], value: a['value'] } }
      }
    end
    { examples: examples, syntax: syntax, semantics: semantics, source: path }
  end

  members.each do |member|
    verbs[member] += frames
  end
end

File.open('verbs.json', 'w').write(verbs.to_json)
puts "Wrote #{verbs.size} to verbs.json"
