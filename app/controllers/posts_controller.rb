class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]

  def index
    @posts = filter_posts
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @post = Post.friendly.find(params[:id])
  end

  def new
    @post = Post.new
    @post.save
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to posts_path, notice: 'Post was successfully created.'
    else
      render :new
    end
  end

  def edit
    @post = Post.friendly.find(params[:id])
  end

  def update
    if @post.update(post_params)
      redirect_to posts_path, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: 'Post was successfully destroyed.'
  end

  private

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :user_id, :status)
  end

  def filter_posts
    if params[:status].present?
      Post.where(status: params[:status])
    else
      Post.all
    end
  end
end
