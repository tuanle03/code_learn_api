# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

describe Web do
  include Rack::Test::Methods

  def app
    Web::UsersAPI
  end

  let(:user) { create(:user, password: '123456') }
  let(:token) { user.generate_jwt }
  let(:post) { create(:post, user: user) }
  let(:feedback) { create(:feedback, user: user, post: post) }
  let(:discussion) { create(:discussion, user: user) }
  let(:comment) { create(:comment, user: user, linked_object: discussion) }

  describe 'GET /web/users' do
    context 'with a valid access token' do
      before do
        create(:feedback, user: user, post: post)
        create(:comment, user: user, linked_object: discussion)
      end

      it 'returns user details and associated data' do
        get '/web/users', {}, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)

        expect(json['user']['id']).to eq(user.id)
        expect(json['user_feedbacks'].length).to eq(1)
        expect(json['user_posts'].length).to eq(1)
        expect(json['user_comments'].length).to eq(1)
        expect(json['user_discussions'].length).to eq(1)
      end
    end

    context 'without a valid access token' do
      it 'returns an unauthorized response' do
        get '/web/users'

        expect(last_response.status).to eq(401)
      end
    end
  end

  describe 'PUT /web/users' do
    context 'with a valid access token and valid parameters' do
      it 'edits the user profile' do
        put '/web/users', { last_name: 'Doe' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Profile updated successfully')
        expect(user.reload.last_name).to eq('Doe')
      end
    end

    context 'without a valid access token' do
      it 'returns an unauthorized response' do
        put '/web/users'

        expect(last_response.status).to eq(401)
      end
    end

    context 'with invalid parameters last_name' do
      it 'returns an success message' do
        put '/web/users', { last_name: '' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Profile updated successfully')
      end
    end

    context 'with invalid parameters first_name' do
      it 'returns an success message' do
        put '/web/users', { first_name: '' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Profile updated successfully')
      end
    end

    context 'with wrong old password' do
      it 'returns an error message' do
        put '/web/users', { old_password: 'wrong_password' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(false)
        expect(json['message']).to eq('New password is required')
      end
    end

    context 'with wrong old password & valid new password' do
      it 'returns an error message' do
        put '/web/users', { old_password: 'wrong_password', new_password: 'new_password', new_password_confirmation: 'new_password' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(false)
        expect(json['message']).to eq('Old password is incorrect')
      end
    end

    context 'with valid old password & valid new password' do
      it 'returns a success message' do
        put '/web/users', { old_password: '123456', new_password: 'new_password', new_password_confirmation: 'new_password' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Profile updated successfully')
      end
    end

    context 'with valid old password & password confirmation mismatch' do
      it 'returns an error message' do
        put '/web/users', { old_password: '123456', new_password: 'new_password', new_password_confirmation: 'wrong_password' }, 'HTTP_TOKEN' => token

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(false)
        expect(json['message']).to eq('Password confirmation does not match')
      end
    end
  end
end
