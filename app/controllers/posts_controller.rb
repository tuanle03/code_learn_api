class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find_by_id(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    post = Post.new(params[:post])

    if post.save
      redirect_to posts_path
    else
      render :new
    end
  end

  def edit
    @post = Post.find_by_id(params[:id])

    if @post.nil?
      redirect_to posts_path
    end
  end

  def update
    post = Post.find_by_id(params[:id])

    if post.update_attributes(params[:post])
      redirect_to posts_path
    else
      render :edit
    end
  end

  def destroy
    post = Post.find_by_id(params[:id])

    if post.destroy
      redirect_to posts_path, notice: "Post deleted"
    else
      redirect_to posts_path, notice: "Post could not be deleted"
    end
  end

  private

  def post_params
    params.require(:post).permit(:user_id, :title, :body, :status, :total_view)
  end
end
