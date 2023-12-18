# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

describe Web do
  include Rack::Test::Methods

  def app
    Web::RegistrationsAPI
  end

  describe 'POST /api/web/registrations' do
    context 'with valid registration parameters' do
      it 'creates a new user and returns a JWT token' do
        post '/web/registrations', {
          user: {
            email: 'new_user@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['token']).to be_present
      end
    end

    context 'when email already exists' do
      before do
        User.create(email: 'existing_user@example.com', password: 'password123')
      end

      it 'returns an error message' do
        post '/web/registrations', {
          user: {
            email: 'existing_user@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['error']).to eq('Email has already been taken')
      end
    end

    context 'when password confirmation does not match' do
      it 'returns an error message' do
        post '/web/registrations', {
          user: {
            email: 'user@example.com',
            password: 'password123',
            password_confirmation: 'password456'
          }
        }

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['error']).to eq('Password confirmation does not match')
      end
    end
  end
end
