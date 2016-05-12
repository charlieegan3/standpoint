require 'open-uri'

require_relative '../config/environment'

class HackerNewsCollector
  def perform(url)
	return if (id = url.match(/[0-9]+$/).to_s).blank?
	data_url = "https://hn.algolia.com/api/v1/items/#{id}"
	data = JSON.parse(open(data_url).read)

	discussion = Discussion.create(
	  title: data["title"],
	  url: url,
      source: "Hacker News"
	)

	save_the_children(discussion, nil, data["children"])
  end

  handle_asynchronously :perform

  private

  def save_the_children(discussion, parent, children)
	children.each do |c|
	  next unless c["text"]
	  comment = Comment.create(
        discussion: discussion,
        parent: parent,
		text: Nokogiri::HTML(c["text"]).css('p').map(&:text).join(" "),
        user: c["author"],
        votes: c["points"]
      )
	  save_the_children(discussion, comment, c["children"])
	end
  end
end
