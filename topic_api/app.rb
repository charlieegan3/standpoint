require 'sinatra'
require 'lda-ruby'
require 'json'

set :port, ENV['PORT']
set :bind, '0.0.0.0'

class TopicAnalyzer
  def initialize(text, topic_count)
    corpus = Lda::Corpus.new
    corpus.add_document(Lda::TextDocument.new(corpus, text))
    @lda = Lda::Lda.new(corpus)
    @lda.num_topics = topic_count
    @lda.em('random')
  end

  def top_words(count)
    @lda.top_words(count).values
  end
end

blacklist = ["-", "http", "https", "feel", "make", "right", "wrong", "things"]

get "/" do
  "Post to this route with a JSON payload. (text, topic_count, top_word_count)"
end

post '/' do
  payload = JSON.parse(request.body.read)
  text = payload["text"].encode("UTF-8", :invalid=>:replace, :replace=>"?")

  ta = TopicAnalyzer.new(text, payload["topic_count"].to_i)
  groups = ta.top_words(payload["top_word_count"].to_i)

  groups.map! { |g| g - blacklist }

  {
    topics: groups.flatten.uniq.sort,
    groups: groups
  }.to_json
end
