require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:discussion) { create(:discussion) }

  it 'is valid with a user, content, linked_object_id, and linked_object_type' do
    comment = Comment.new(user: user, content: 'Test Content', linked_object: discussion)
    expect(comment).to be_valid
  end

  it 'is invalid without content' do
    comment = Comment.new(user: user, content: nil, linked_object: discussion)
    comment.valid?
    expect(comment.errors[:content]).to include("can't be blank")
  end

  it 'is invalid without a user' do
    comment = Comment.new(user: nil, content: 'Test Content', linked_object: discussion)
    comment.valid?
    expect(comment.errors[:user]).to include('must exist')
  end

  it 'is invalid without a linked_object_id' do
    comment = Comment.new(user: user, content: 'Test Content', linked_object_id: nil, linked_object_type: 'Discussion')
    comment.valid?
    expect(comment.errors[:linked_object_id]).to include("can't be blank")
  end

  it 'is invalid without a linked_object_type' do
    comment = Comment.new(user: user, content: 'Test Content', linked_object_id: discussion.id, linked_object_type: nil)
    comment.valid?
    expect(comment.errors[:linked_object_type]).to include("can't be blank")
  end

  it 'belongs to a user' do
    association = Comment.reflect_on_association(:user)
    expect(association.macro).to eq(:belongs_to)
  end

  it 'belongs to a polymorphic linked_object' do
    association = Comment.reflect_on_association(:linked_object)
    expect(association.macro).to eq(:belongs_to)
    expect(association.options[:polymorphic]).to eq(true)
  end

  it 'has an approved scope that filters comments by status' do
    create(:comment, status: 'approved', linked_object: discussion)
    create(:comment, status: 'pending', linked_object: discussion)
    create(:comment, status: 'approved', linked_object: discussion)

    expect(Comment.approved.count).to eq(2)
  end
end
