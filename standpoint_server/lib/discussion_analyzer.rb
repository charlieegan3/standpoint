require "json"
require "net/http"

require_relative '../config/environment'

class DiscussionAnalyzer
  def perform(discussion)
    points = get_points(discussion.comments)
  end

  handle_asynchronously :perform

  private
  def get_points(comments)
    uri = URI('http://point_extractor:3456/points')
    http = Net::HTTP.new(uri.host, uri.port)
    comments.each do |c|
      req = Net::HTTP::Post.new(uri)
      req.body = c.text
      resp = http.request(req)
      next unless http.request(req).message == "OK"
      JSON.parse(resp.body).each do |point|
        Point.create(
          comment: c, extract: point["extract"], pattern: point["pattern"])
      end
    end
  end
end
