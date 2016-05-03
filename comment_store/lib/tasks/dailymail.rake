require 'open-uri'

require_relative '../../config/environment'

def save_comments(parent, comments)
  comments.each do |c|
    comment = Comment.create(parent: parent, body: c["message"])
    save_comments(comment, c["replies"]["comments"])
  end
end

task :dailymail, :id do |t, args|
  exit if args[:id].blank?

  url = "http://www.dailymail.co.uk/reader-comments/p/asset/readcomments/#{args[:id]}?max=100&sort=voteRating&order=desc&rcCache=shout"

  data = JSON.parse(open(url).read)

  article = Comment.create(
    parent: nil,
    body: "Daily Mail Article #{args[:id]}",
    source: "http://www.dailymail.co.uk" + data["payload"]["page"].first["assetUrl"]
  )

  save_comments(article, data["payload"]["page"])
end
