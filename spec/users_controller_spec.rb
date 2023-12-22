require 'spec_helper'
require 'factory_bot'
require 'faker'
require 'simplecov'
require 'api_helper'

describe 'User registration API' do
  include Rack::Test::Methods
  include JsonWebToken

  def app
    App.new
  end

  describe 'POST /signup' do
    context 'with valid data' do
      it 'creates a new user and returns success' do
        valid_data = { email: Faker::Internet.email, password: 'Password@123' }
        post '/signup', valid_data.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response).to be_ok
        response_body = JSON.parse(last_response.body)
        expect(response_body['status']).to eq('success')
        expect(response_body['message']).to eq('User successfully registered')
      end
    end

    context 'with invalid data' do
      it 'returns an error message' do
        invalid_data = { email: 'invalid_email', password: 'Short@123' }

        post '/signup', invalid_data.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response).to be_ok
        response_body = JSON.parse(last_response.body)
        expect(response_body['status']).to eq('error')
        expect(response_body['message']).to include('has an invalid format')
      end
    end

    context 'with unexpected error' do
      it 'returns an error message' do
        allow(User).to receive(:new).and_raise(StandardError, 'Unexpected error')

        post '/signup', {}.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response).to be_ok
        response_body = JSON.parse(last_response.body)
        expect(response_body['status']).to eq('error')
        expect(response_body['message']).to eq('Unexpected error: Unexpected error')
      end
    end
  end

   describe 'POST /login' do
    context 'with valid credentials and two-factor disabled' do
      let(:user) { create(:user, two_factor_enabled: false, otp_secret: ROTP::Base32.random_base32, password: 'Password@123', password_confirmation: 'Password@123') }

      it 'logs in successfully and returns a token' do
        post '/login', { email: user.email, password: 'Password@123' }.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response).to be_ok
        response_body = JSON.parse(last_response.body)
        expect(response_body['status']).to eq('success')
        expect(response_body['message']).to eq('Successfully login')
        expect(response_body['token']).to be_present
      end
    end

    context 'with valid credentials and two-factor enabled' do
      let(:user) { create(:user, two_factor_enabled: true, password: 'Password@123', password_confirmation: 'Password@123') }

      it 'returns an OTP along with the token' do
        post '/login', { email: user.email, password: 'Password@123' }.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response).to be_ok
        response_body = JSON.parse(last_response.body)
        expect(response_body['status']).to eq('error')
        expect(response_body['message']).to eq('Cannot generate OTP, please enable 2FA')
      end
    end

    context 'with invalid credentials' do
      it 'returns an error message' do
        post '/login', { email: 'nonexistent@example.com', password: 'invalidpassword' }.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response).to be_ok
        response_body = JSON.parse(last_response.body)
        expect(response_body['status']).to eq('error')
        expect(response_body['message']).to eq('Invalid username or password')
      end
    end

    context 'with unexpected errors' do
      it 'returns an error message' do
        allow(User).to receive(:find_by).and_raise(StandardError, 'Unexpected error')

        post '/login', { email: 'test@example.com', password: 'Password@123' }.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response).to be_ok
        response_body = JSON.parse(last_response.body)
        expect(response_body['status']).to eq('error')
        expect(response_body['message']).to eq('Cannot generate OTP, please enable 2FA')
      end
    end
  end

  describe 'POST /enable_2fa_authentication' do

    before do
      @user = FactoryBot.create(:user, email: Faker::Internet.email, password: 'Password@123', password_confirmation: 'Password@123')
    end

    context 'when user is found' do

      it 'enables 2FA and returns a QR code' do
        post '/enable_2fa_authentication', { email: @user.email }.to_json

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('image/png')
      end
    end

    context 'when user is not found' do
      it 'returns an error message' do
        post '/enable_2fa_authentication', { email: 'nonexistent@example.com' }.to_json

        expect(last_response.status).to eq(200)
        response_json = JSON.parse(last_response.body)
        expect(response_json['status']).to eq('error')
        expect(response_json['message']).to eq('User not found')
      end
    end

    context 'when an unexpected error occurs' do
      it 'returns an error message' do
        email = Faker::Internet.email
        allow(User).to receive(:find_by).and_raise(StandardError, 'Something went wrong')

        post '/enable_2fa_authentication', { email: email, token: @token }.to_json

        expect(last_response.status).to eq(200)
        response_json = JSON.parse(last_response.body)
        expect(response_json['status']).to eq('error')
        expect(response_json['message']).to eq('Unexpected error: Something went wrong')
      end
    end
  end
end