require 'sinatra/activerecord'
require 'bcrypt'

class User < ActiveRecord::Base
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :password,presence: true, format: { with: /\A(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]]) /x }, if: :apply_password_validation?
  validate :validate_email_format

  def validate_email_format
    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    unless email_regex.match?(email)
      errors.add(:email, 'has an invalid format')
    end
  end

  def update_password(new_password)
    @password_digest = BCrypt::Password.create(new_password)
  end

  def apply_password_validation?
    new_record? || password_digest_changed?
  end
end
