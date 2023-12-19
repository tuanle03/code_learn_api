# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

describe Web do
  include Rack::Test::Methods

  def app
    Web::SessionsAPI
  end

  describe 'POST api/web/sessions/sign_in' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns a JWT token' do
        post '/web/sessions/sign_in', { email: user.email, password: 'password123' }

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['token']).to eq(user.generate_jwt)
      end
    end

    context 'with invalid credentials' do
      it 'returns an error message' do
        post '/web/sessions/sign_in', { email: user.email, password: 'wrong_password' }

        expect(last_response.status).to eq(401)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(false)
        expect(json['message']).to eq('Invalid email or password')
      end
    end
  end

  describe 'DELETE /api/web/sessions/sign_out' do
    let(:user) { create(:user) }
    let(:token) { user.generate_jwt }

    context 'with a valid token' do
      it 'returns a success response' do
        delete '/web/sessions/sign_out', {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
      end
    end

    context 'with an invalid token' do
      it 'returns an unauthorized response' do
        delete '/web/sessions/sign_out', {}, 'HTTP_AUTHORIZATION' => 'Bearer invalid_token'
        expect(last_response.status).to eq(401)
      end
    end
  end
end
