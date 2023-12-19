# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

describe Web do
  include Rack::Test::Methods

  def app
    Web::PostsAPI
  end

  let(:user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:token) { user.generate_jwt }
  let(:admin_token) { admin_user.generate_jwt }

  describe 'GET /web/posts' do
    context 'with valid parameters' do
      it 'returns a list of posts' do
        create_list(:post, 5, status: 'approved', user: user)

        get '/web/posts', { limit: 3 }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['posts'].length).to eq(3)
      end
    end
  end

  describe 'GET /web/posts/newest' do
    context 'with valid parameters' do
      it 'returns a list of newest posts' do
        create_list(:post, 5, status: 'approved', user: user)

        get '/web/posts/newest', { limit: 3 }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['posts'].length).to eq(3)
      end
    end
  end

  describe 'GET /web/posts/most_viewed' do
    context 'with valid parameters' do
      it 'returns a list of most viewed posts' do
        create_list(:post, 5, status: 'approved', user: user)

        get '/web/posts/most_viewed', { limit: 3 }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['posts'].length).to eq(3)
      end
    end
  end

  describe 'GET /web/posts/:id' do
    let(:post) { create(:post, status: 'approved', user: user) }

    context 'with a valid post ID' do
      it 'returns the details of the post' do
        get "/web/posts/#{post.id}", {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['post']['id']).to eq(post.id)
      end
    end

    context 'with an invalid post ID' do
      it 'returns an error message' do
        get '/web/posts/999', {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(false)
        expect(json['error']).to eq('Post not found')
      end
    end
  end

  describe 'POST /web/posts' do
    context 'with valid parameters' do
      it 'creates a post' do
        post '/web/posts', { title: 'New Post', body: 'Lorem ipsum' }, 'HTTP_AUTHORIZATION' => "Bearer #{admin_token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Post created successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        post '/web/posts', { title: '', body: '' }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(400)
      end
    end
  end

  describe 'PUT /web/posts/:id' do
    let(:post) { create(:post, user: user) }

    context 'with valid parameters' do
      it 'updates the post' do
        put "/web/posts/#{post.id}", { new_title: 'Updated Title', new_body: 'Updated Body' }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Post updated successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        put "/web/posts/#{post.id}", { new_title: '', new_body: '' }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Post updated successfully')
      end
    end
  end

  describe 'DELETE /web/posts/:id' do
    let(:post) { create(:post, user: user) }

    context 'with valid parameters' do
      it 'deletes the post' do
        delete "/web/posts/#{post.id}", {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Post deleted successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        delete '/web/posts/999', {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(false)
        expect(json['error']).to eq('Post cannot be deleted')
      end
    end
  end

  describe 'GET /web/posts/user/:id' do
    before do
      create_list(:post, 3, user: user, status: 'approved')
    end

    context 'with a valid user ID' do
      it 'returns a list of posts by user' do
        get "/web/posts/user/#{user.id}", {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['posts'].length).to eq(3)
      end
    end
  end

  describe 'PUT /web/posts/approve/:id' do
    let(:post_to_approve) { create(:post, status: 'pending') }

    context 'as an admin user' do
      it 'approves the post' do
        put "/web/posts/approve/#{post_to_approve.id}", {}, 'HTTP_AUTHORIZATION' => "Bearer #{admin_token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Post approved successfully')
      end
    end

    context 'as a regular user' do
      it 'returns an unauthorized response' do
        put "/web/posts/approve/#{post_to_approve.id}", {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(false)
        expect(json['error']).to eq('You are not authorized')
      end
    end
  end

  describe 'GET /web/posts/:id/feedbacks' do
    let(:post) { create(:post, status: 'approved', user: user) }

    before do
      create(:feedback, post: post, user: user)
    end

    context 'with a valid post ID' do
      it 'returns a list of feedbacks' do
        get "/web/posts/#{post.id}/feedbacks", {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['feedbacks'].length).to eq(1)
      end
    end

    context 'with an invalid post ID' do
      it 'returns an error message' do
        get '/web/posts/999/feedbacks', {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(400)
      end
    end
  end

  describe 'POST /web/posts/:id/feedbacks' do
    before do
      create(:post, status: 'approved', user: user)
    end

    context 'with valid parameters' do
      it 'creates a feedback' do
        post "/web/posts/1/feedbacks", { content: 'Lorem ipsum' }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Feedback created successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        post "/web/posts/1/feedbacks", { content: '' }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(400)
      end
    end
  end
end
