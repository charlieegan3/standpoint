require 'open-uri'

require_relative '../config/environment'

class HackerNewsCurrentTopCollector
  def perform
    doc = Nokogiri::HTML(open("https://news.ycombinator.com").read)
    url = "https://news.ycombinator.com" +
      doc.at_css(".subtext a:last-child")['href']
    existing.destroy if existing = Discussion.find_by_url(url)
    HackerNewsCollector.new.perform(url)
  end

  handle_asynchronously :perform
end
