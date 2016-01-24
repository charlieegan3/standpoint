require 'open-uri'

require_relative '../../config/environment'

def save_comments_for_replies(parent, replies)
  return if replies.blank?
  replies["data"]["children"].each do |r|
    comment = Comment.create(parent: parent, body: r["data"]["body"])
    save_comments_for_replies(comment, r["data"]["replies"])
  end
end

task :reddit, :url do |t, args|
  exit if args[:url].blank?

  post, comments = JSON.parse(open(args[:url]).read)

  parent_comment = Comment.create(
    parent: nil,
    body: post["data"]["children"][0]["data"]["selftext"],
    source: args[:url].gsub(".json", "")
  )

  comments["data"]["children"].each do |c|
    comment = Comment.create(parent: parent_comment, body: c["data"]["body"])
    save_comments_for_replies(comment, c["data"]["replies"])
  end
end
