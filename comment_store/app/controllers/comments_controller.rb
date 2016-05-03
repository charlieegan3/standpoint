class CommentsController < ApplicationController
  def index
    @comments = Comment.where(parent: nil).order(created_at: :desc)
  end

  def show
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @comment.ancestors(params[:flat]) }
    end
  end
end
