class FeedbacksController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]
  belongs_to :user
  belongs_to :post

  def index
    @feedbacks = Feedback.all
  end

  def new
    @feedback = Feedback.new
  end

  def show
    @feedback = Feedback.find(params[:id])
  end

  def create
    @feedback = Feedback.new(feedback_params)
    if @feedback.save
      redirect_to @feedback
    else
      render :new
    end
  end

  def update
    @feedback = Feedback.find(params[:id])
    if @feedback.update(feedback_params)
      redirect_to @feedback
    else
      render :edit
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy
    redirect_to feedbacks_path
  end

  private

  def feedback_params
    params.require(:feedback).permit(:user_id, :post_id, :content)
  end
end
