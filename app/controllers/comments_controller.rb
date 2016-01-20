class CommentsController < ApplicationController
  def index
    @comments = Comment.where(parent: nil)
  end

  def show
    @comment = Comment.find(params[:id])
  end
end
