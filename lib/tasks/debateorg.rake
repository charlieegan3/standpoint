require 'open-uri'

require_relative '../../config/environment'

task :debateorg, :url do |t, args|
  exit if args[:url].blank?

  doc = Nokogiri::HTML(open(args[:url]))
  doc.css('.photo').remove

  parent = nil
  doc.css('.round-inner').each do |e|
    parent = Comment.create(
      parent: parent,
      body: e.text.strip,
      source: args[:url]
    )
  end
end
