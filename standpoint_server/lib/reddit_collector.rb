require 'open-uri'

require_relative '../config/environment'

class RedditCollector
  def perform(url)
    data_url = url.gsub(/\/$/, "") + ".json"
    post, comments = JSON.parse(open(data_url, "User-Agent" => "Chrome").read)

	discussion = Discussion.create(
      title: post["data"]["children"].first["data"]["title"],
	  url: url,
	  source: "Reddit"
	)
    save_the_children(discussion, nil, comments)
  end

  handle_asynchronously :perform

  private
  def save_the_children(discussion, parent, replies)
	return if replies.blank?
	replies["data"]["children"].each do |r|
      r["data"]["ups"] = 0 if r["data"]["ups"].nil?
      r["data"]["downs"] = 0 if r["data"]["downs"].nil?
	  comment = Comment.create(
        discussion: discussion,
        parent: parent,
        text: Nokogiri::HTML(r["data"]["body"]).text,
        user: r["data"]["author"],
        votes: r["data"]["ups"] - r["data"]["downs"],
      )
	  save_the_children(discussion, comment, r["data"]["replies"])
	end
  end
end
