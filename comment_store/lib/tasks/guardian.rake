require 'open-uri'

require_relative '../../config/environment'

task :guardian, :id do |t, args|
  exit if args[:id].blank?

  url = "https://api.nextgen.guardianapps.co.uk/discussion/p/#{args[:id]}.json?page=1&orderBy=mostRecommended&pageSize=100&displayThreaded=true&maxResponses=5"
  html = JSON.parse(open(url).read)['commentsHtml']
  doc = Nokogiri::HTML(html)

  doc.css('svg, img, span, button, a').remove
  doc.css('.d-discussion__size-message').remove
  doc.css('.discussion__pagination').remove
  doc.css('.d-report-comment-form').remove

  article = Comment.create(
    parent: nil,
    body: "Guardian Article #{args[:id]}",
    source: "http://gu.com/p/#{args[:id]}"
  )

  doc.css('body .d-discussion > .d-thread--comments > li.d-comment').each do |c|
    comment = Comment.create(
      parent: article,
      body: c.at_css('.d-comment__body').text.strip,
    )
    c.css('.d-thread--responses > li.d-comment .d-comment__content').each do |r|
      Comment.create(parent: comment, body: r.text.strip)
    end
  end
end
