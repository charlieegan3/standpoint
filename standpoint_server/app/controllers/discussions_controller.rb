class DiscussionsController < ApplicationController
  def index
    @discussions = Discussion.all.order('created_at DESC')
    @jobs = Delayed::Job.count
  end

  def show
    @discussion = Discussion.find(params[:id])
  end

  def create
    url = params[:url]
    if url.match(/^https:\/\/news\.ycombinator\.com\/item\?id=[0-9]+$/)
      HackerNewsCollector.new.perform(url)
      return redirect_to root_path, flash: { notice: "Processing HN" }
    elsif url.match(/^https:\/\/www\.reddit\.com\/r\/\w+\/comments\//)
      RedditCollector.new.perform(url)
      return redirect_to root_path, flash: { notice: "Processing Reddit" }
    end
    redirect_to root_path, flash: { error: "Bad URL" }
  end

  def reset
    Delayed::Job.delete_all
    redirect_to root_path, flash: { error: "All jobs deleted" }
  end
end
