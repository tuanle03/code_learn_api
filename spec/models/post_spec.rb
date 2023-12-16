require 'rails_helper'

RSpec.describe Post, type: :model do
  it "is valid with a title" do
    post = Post.new(title: "Test Title")
    expect(post).to be_valid
  end

  it "is invalid without a title" do
    post = Post.new(title: nil)
    post.valid?
    expect(post.errors[:title]).to include("can't be blank")
  end
end
