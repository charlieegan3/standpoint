require 'open-uri'

require_relative '../../config/environment'

def save_the_children(parent, children)
  children.each do |c|
    next unless c["text"]
    comment = Comment.create(parent: parent, body: Nokogiri::HTML(c["text"]).text)
    save_the_children(comment, c["children"])
  end
end

task :hackernews, :id do |t, args|
  exit if args[:id].blank?

  url = "https://hn.algolia.com/api/v1/items/"+ args[:id]

  data = JSON.parse(open(url).read)

  article = Comment.create(
    parent: nil,
    body: data["title"],
    source: "https://news.ycombinator.com/item?id="+args[:id]
  )

  save_the_children(article, data["children"])
end
