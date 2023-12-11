class CommentsController < ApplicationController

  def index
    @comments = Comment.all
  end

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)

    if @comment.save
      redirect_to comments_path, notice: "Comment was successfully created."
    else
      render :new
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])

    if @comment.update(comment_params)
      redirect_to comments_path, notice: "Comment was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    Comment.find(params[:id]).destroy
    redirect_to comments_path, notice: "Comment was successfully deleted."
  end

  private

  def comment_params
    params.require(:comment).permit(:user_id, :linked_object_id, :linked_object_type, :content, :status)
  end
end
