class CommentsController < ApplicationController
  def show
    render json: Comment.find(params[:id])
  end
end
