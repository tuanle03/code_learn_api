require 'rails_helper'

RSpec.describe Feedback, type: :model do
  let(:user) { create(:user) }
  let(:post) { create(:post) }

  it 'is valid with a user, post, and content' do
    feedback = Feedback.new(user: user, post: post, content: 'Test Content')
    expect(feedback).to be_valid
  end

  it 'is invalid without content' do
    feedback = Feedback.new(user: user, post: post, content: nil)
    feedback.valid?
    expect(feedback.errors[:content]).to include("can't be blank")
  end

  it 'belongs to a user' do
    association = Feedback.reflect_on_association(:user)
    expect(association.macro).to eq(:belongs_to)
  end

  it 'belongs to a post' do
    association = Feedback.reflect_on_association(:post)
    expect(association.macro).to eq(:belongs_to)
  end

  it 'has many comments' do
    association = Feedback.reflect_on_association(:comments)
    expect(association.macro).to eq(:has_many)
  end

  it 'has many votes' do
    association = Feedback.reflect_on_association(:votes)
    expect(association.macro).to eq(:has_many)
  end

  it 'returns the correct total_comments' do
    feedback = create(:feedback, user: user, post: post)
    create_list(:comment, 2, linked_object: feedback)
    expect(feedback.total_comments).to eq(2)
  end
end
