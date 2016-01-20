class CommentsController < ApplicationController
  def index
    @comments = Comment.where(parent: nil)
  end
end
