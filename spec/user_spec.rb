require 'spec_helper'
require 'bcrypt'

describe User do
  let(:valid_email) { 'user@example.com' }
  let(:valid_password) { 'Password1#' }

  describe 'validations' do
    context 'when creating a new user' do
      it 'is valid with a valid email and password' do
        user = User.new(email: valid_email, password: valid_password)
        expect(user).to be_valid
      end

      it 'is invalid without an email' do
        user = User.new(password: valid_password)
        expect(user).to_not be_valid
      end

      it 'is invalid without a password' do
        user = User.new(email: valid_email)
        expect(user).to_not be_valid
      end

      it 'is invalid with an invalid email format' do
        user = User.new(email: 'invalid_email', password: valid_password)
        expect(user).to_not be_valid
      end

      it 'is invalid with a password that does not meet the requirements' do
        user = User.new(email: valid_email, password: 'weakpassword')
        expect(user).to_not be_valid
      end
    end

    context 'when updating the password' do
      let(:user) { User.create(email: valid_email, password: valid_password) }

      it 'is valid with a new valid password' do
        user.update_password('NewPassword2$')
        expect(user).to be_valid
      end

      it 'is invalid with a new weak password' do
        user.update_password('weakpassword')
        expect(user).to_not be_valid
      end
    end
  end
end
