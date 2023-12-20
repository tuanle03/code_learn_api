# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

describe Web do
  include Rack::Test::Methods

  def app
    Web::DiscussionsAPI
  end

  let(:user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:token) { user.generate_jwt }
  let(:admin_token) { admin_user.generate_jwt }

  describe 'GET /web/discussions' do
    context 'with valid parameters' do
      it 'returns a list of discussions' do
        create_list(:discussion, 5, status: 'approved', user: user)

        get '/web/discussions', { limit: 3 }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['discussions'].length).to eq(3)
      end
    end
  end

  describe 'GET /web/discussions/newest' do
    context 'with valid parameters' do
      it 'returns a list of discussions' do
        create_list(:discussion, 5, status: 'approved', user: user)

        get '/web/discussions/newest', { limit: 3 }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['discussions'].length).to eq(3)
      end
    end
  end

  describe 'GET /web/discussions/most_commented' do
    context 'with valid parameters' do
      it 'returns a list of discussions' do
        create_list(:discussion, 5, status: 'approved', user: user)
        create_list(:comment, 5, user: user)

        get '/web/discussions/most_commented', { limit: 3 }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['discussions'].length).to eq(1)
      end
    end
  end

  describe 'GET /web/discussions/:id' do
    context 'with valid parameters' do
      it 'returns a discussion' do
        discussion = create(:discussion, status: 'approved', user: user)

        get "/web/discussions/#{discussion.id}", {}, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['discussion']['title']).to eq(discussion.title)
      end
    end
  end

  describe 'POST /web/discussions' do
    context 'with valid parameters' do
      it 'creates a discussion' do
        post '/web/discussions', { title: 'New Discussion', content: 'Lorem ipsum' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['discussion']['title']).to eq('New Discussion')
     end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        post '/web/discussions', { title: '', content: '' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['error']).to eq('content is empty, title is empty')
      end
    end
  end

  describe 'PUT /web/discussions/:id' do
    let(:discussion) { create(:discussion, user: user) }

    context 'with valid parameters' do
      it 'updates the discussion' do
        put "/web/discussions/#{discussion.id}", { content: 'Updated Content' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Discussion updated successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        put "/web/discussions/#{discussion.id}", { content: '' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['error']).to eq('content is empty')
      end
    end
  end

  describe 'DELETE /web/discussions/:id' do
    before do
      create(:discussion, user: user)
    end

    context 'with admin and valid parameters' do
      it 'deletes the discussion' do
        delete '/web/discussions/1', {}, 'HTTP_TOKEN' => admin_token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Discussion deleted successfully')
      end
    end

    context 'with user and invalid parameters' do
      it 'returns an error message' do
        delete '/web/discussions/999', {}, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['error']).to eq('Discussion not found')
      end
    end

    context 'with user and valid parameters' do
      it 'deletes the discussion' do
        delete "/web/discussions/1", {}, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Discussion deleted successfully')
      end
    end
  end

  describe 'PUT /web/discussions/:id/reject' do
    before do
      create(:discussion, user: user)
    end

    context 'with admin and valid parameters' do
      it 'rejects the discussion' do
        put '/web/discussions/1/reject', {}, 'HTTP_TOKEN' => admin_token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Discussion rejected successfully')
      end
    end

    context 'with user and valid parameters' do
      it 'returns an error message' do
        put '/web/discussions/1/reject', {}, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Discussion rejected successfully')
      end
    end
  end

  describe 'GET /web/discussions/:id/comments' do
    context 'with valid parameters' do
      it 'returns a list of comments' do
        discussion = create(:discussion, status: 'approved', user: user)
        create(:comment, :approved, linked_object: discussion, user: user)

        get "/web/discussions/#{discussion.id}/comments", {}, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['comments'].length).to eq(1)
      end
    end
  end

  describe 'POST /web/discussions/:id/comments' do
    context 'with valid parameters' do
      it 'creates a comment' do
        discussion = create(:discussion, status: 'approved', user: user)

        post "/web/discussions/#{discussion.id}/comments", { content: 'Lorem ipsum' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Comment created successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        discussion = create(:discussion, status: 'approved', user: user)

        post "/web/discussions/#{discussion.id}/comments", { content: '' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['error']).to eq('content is empty')
      end
    end
  end

  describe 'PUT /web/discussions/:id/comments/:comment_id' do
    let(:discussion) { create(:discussion, status: 'approved', user: user) }
    let(:comment) { create(:comment, :approved, linked_object: discussion, user: user) }

    context 'with valid parameters' do
      it 'updates the comment' do
        put "/web/discussions/#{discussion.id}/comments/#{comment.id}", { content: 'Updated Content' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Comment updated successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        put "/web/discussions/#{discussion.id}/comments/#{comment.id}", { content: '' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['error']).to eq('content is empty')
      end
    end
  end

  describe 'PUT /web/discussions/:id/comments/:comment_id/reject' do
    let(:discussion) { create(:discussion, status: 'approved', user: user) }
    let(:comment) { create(:comment, :approved, linked_object: discussion, user: user) }

    context 'with admin and valid parameters' do
      it 'rejects the comment' do
        put "/web/discussions/#{discussion.id}/comments/#{comment.id}/reject", {}, 'HTTP_TOKEN' => admin_token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Comment rejected successfully')
      end
    end

    context 'with user and valid parameters' do
      it 'returns an error message' do
        put "/web/discussions/#{discussion.id}/comments/#{comment.id}/reject", {}, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Comment rejected successfully')
      end
    end
  end

  describe 'DELETE /web/discussions/:id/comments/:comment_id' do
    let(:discussion) { create(:discussion, status: 'approved', user: user) }
    let(:comment) { create(:comment, :approved, linked_object: discussion, user: user) }

    context 'with admin and valid parameters' do
      it 'deletes the comment' do
        delete "/web/discussions/#{discussion.id}/comments/#{comment.id}", {}, 'HTTP_TOKEN' => admin_token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Comment deleted successfully')
      end
    end

    context 'with user and valid parameters' do
      it 'deletes the comment' do
        delete "/web/discussions/#{discussion.id}/comments/#{comment.id}", {}, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Comment deleted successfully')
      end
    end
  end
end
