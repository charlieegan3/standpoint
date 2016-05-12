class DiscussionsController < ApplicationController
  def index
    @discussions = Discussion.all
  end
end
