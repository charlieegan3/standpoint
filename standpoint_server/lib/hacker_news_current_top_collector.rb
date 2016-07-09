require 'open-uri'

require_relative '../config/environment'

class HackerNewsCurrentTopCollector
  def perform
    doc = Nokogiri::HTML(open("https://news.ycombinator.com").read)
    path = doc.at_css(".subtext a:last-child")['href']
    HackerNewsCollector.new.perform("https://news.ycombinator.com#{path}")
  end

  handle_asynchronously :perform
end
