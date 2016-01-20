require 'open-uri'

require_relative '../../config/environment'

task :stackexchange, :id, :site do |t, args|
  exit if args[:id].blank?

  question_url = "https://api.stackexchange.com/2.2/questions/#{args[:id]}?order=desc&sort=activity&site=#{args[:site]}&filter=!9YdnSJ*_T"
  answer_url = "https://api.stackexchange.com/2.2/questions/#{args[:id]}/answers?order=desc&sort=activity&site=#{args[:site]}&filter=!9YdnSM68f"

  question_data = JSON.parse(open(question_url).read)
  answer_data = JSON.parse(open(answer_url).read)

  question = Comment.create(
    parent: nil,
    body: question_data["items"].first["body_markdown"],
    source: question_data["items"].first["link"]
  )

  answer_data["items"].each do |a|
    Comment.create(
      parent: question,
      body: a["body_markdown"]
    )
  end
end
