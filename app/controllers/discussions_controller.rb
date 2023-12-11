class DiscussionsController < ApplicationController

  def index
    @discussions = Discussion.all
  end

  def show
    @discussion = Discussion.find(params[:id])
  end

  def new
    @discussion = Discussion.new
  end

  def create
    @discussion = Discussion.new(discussion_params)
    if @discussion.save
      redirect_to @discussion
    else
      render :new
    end
  end

  def edit
    @discussion = Discussion.find(params[:id])
  end

  def update
    @discussion = Discussion.find(params[:id])
    if @discussion.update(discussion_params)
      redirect_to @discussion
    else
      render :edit
    end
  end

  def destroy
    @discussion = Discussion.find(params[:id])
    @discussion.destroy
    redirect_to discussions_path
  end

  private

  def discussion_params
    params.require(:discussion).permit(:user_id, :content, :status)
  end
end
