require 'rails_helper'

RSpec.describe Discussion, type: :model do
  let(:user) { create(:user) }

  it 'is valid with a user, title, and content' do
    discussion = Discussion.new(user: user, title: 'Test Title', content: 'Test Content')
    expect(discussion).to be_valid
  end

  it 'is invalid without a title' do
    discussion = Discussion.new(user: user, title: nil, content: 'Test Content')
    discussion.valid?
    expect(discussion.errors[:title]).to include("can't be blank")
  end

  it 'is invalid with a short title' do
    discussion = Discussion.new(user: user, title: 'Shor', content: 'Test Content')
    discussion.valid?
    expect(discussion.errors[:title]).to include('is too short (minimum is 5 characters)')
  end

  it 'is invalid with a long title' do
    discussion = Discussion.new(user: user, title: 'a' * 101, content: 'Test Content')
    discussion.valid?
    expect(discussion.errors[:title]).to include('is too long (maximum is 100 characters)')
  end

  it 'is invalid without content' do
    discussion = Discussion.new(user: user, title: 'Test Title', content: nil)
    discussion.valid?
    expect(discussion.errors[:content]).to include("can't be blank")
  end

  it 'belongs to a user' do
    association = Discussion.reflect_on_association(:user)
    expect(association.macro).to eq(:belongs_to)
  end

  it 'has many comments' do
    association = Discussion.reflect_on_association(:comments)
    expect(association.macro).to eq(:has_many)
  end

  it 'has many votes' do
    association = Discussion.reflect_on_association(:votes)
    expect(association.macro).to eq(:has_many)
  end

  it 'has a friendly_id' do
    discussion = create(:discussion, title: 'Test Discussion')
    expect(discussion.slug).to eq('test-discussion')
  end

  it 'returns the correct total_comments' do
    discussion = create(:discussion)
    create_list(:comment, 2, linked_object: discussion)
    expect(discussion.total_comments).to eq(2)
  end

  it 'has a newest scope that orders discussions by created_at in descending order' do
    create(:discussion, created_at: 2.days.ago)
    create(:discussion, created_at: 1.day.ago)
    create(:discussion, created_at: 3.days.ago)

    expect(Discussion.newest.pluck(:id)).to eq([2, 1, 3])
  end

  it 'has an approved scope that filters discussions by status' do
    create(:discussion, status: 'approved')
    create(:discussion, status: 'pending')
    create(:discussion, status: 'approved')

    expect(Discussion.approved.count).to eq(2)
  end

  it 'has a most_commented scope that orders discussions by the number of comments in descending order' do
    discussion1 = create(:discussion)
    discussion2 = create(:discussion)
    create(:comment, linked_object: discussion1)
    create(:comment, linked_object: discussion2)
    create(:comment, linked_object: discussion1)

    expect(Discussion.most_commented.reload.pluck(:id)).to eq([discussion1.id, discussion2.id])
  end
end
