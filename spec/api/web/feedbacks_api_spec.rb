# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'

describe Web do
  include Rack::Test::Methods

  def app
    Web::FeedbacksAPI
  end

  let(:user) { create(:user) }
  let(:token) { user.generate_jwt }

  before do
    create(:post, :approved, user: user)
  end

  describe 'POST /web/feedbacks' do
    context 'with valid parameters' do
      it 'creates a feedback' do
        post '/web/feedbacks', { content: 'Feedback content', post_id: 1 }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Feedback created')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        post '/web/feedbacks', { content: '', post_id: 1 }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(400)
      end
    end
  end

  describe 'GET /web/feedbacks/:id' do
    let(:feedback) { create(:feedback, user_id: user.id) }

    context 'with a valid feedback ID' do
      it 'returns the details of the feedback' do
        get "/web/feedbacks/#{feedback.id}", {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['feedback']['id']).to eq(feedback.id)
      end
    end

    context 'with an invalid feedback ID' do
      it 'returns an error message' do
        get '/web/feedbacks/999', {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(400)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(false)
        expect(json['message']).to eq('Feedback not found')
      end
    end
  end

  describe 'DELETE /web/feedbacks/:id' do
    let(:feedback) { create(:feedback, user: user) }

    context 'with a valid feedback ID' do
      it 'deletes the feedback' do
        delete "/web/feedbacks/#{feedback.id}", {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Feedback deleted')
      end
    end

    context 'with an invalid feedback ID' do
      it 'returns an error message' do
        delete '/web/feedbacks/999', {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(400)
      end
    end
  end

  describe 'PUT /web/feedbacks/:id' do
    let(:feedback) { create(:feedback, user: user) }

    context 'with valid parameters' do
      it 'updates the feedback' do
        put "/web/feedbacks/#{feedback.id}", { new_content: 'Updated content' }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['success']).to eq(true)
        expect(json['message']).to eq('Feedback updated')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        put "/web/feedbacks/#{feedback.id}", { new_content: '' }, 'HTTP_AUTHORIZATION' => "Bearer #{token}"

        expect(last_response.status).to eq(400)
      end
    end
  end
end
