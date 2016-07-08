require 'open-uri'

require_relative '../config/environment'

class HackerNewsCurrentTopCollector
  def perform
    doc = Nokogiri::HTML(open("https://news.ycombinator.com").read)
    HackerNewsCollector.new.perform(doc.at_css(".subtext a:last-child")['href'])
  end

  handle_asynchronously :perform
end
