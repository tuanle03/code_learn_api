require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  it 'is valid with a title' do
    post = Post.new(title: 'Test Title', user: user)
    expect(post).to be_valid
  end

  it 'is invalid without a title' do
    post = Post.new(title: nil, user: user)
    post.valid?
    expect(post.errors[:title]).to include("can't be blank")
  end
end
