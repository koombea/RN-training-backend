# frozen_string_literal: true

# Members model
class Member < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :validatable

  validates :name, presence: true
  validates :email, uniqueness: true

  attr_accessor :session_token

  def session
    {
      name: name,
      email: email,
      session_token: session_token
    }
  end

  def generate_session_token
    self.session_token = JsonWebToken.encode(token: redis_token)
  end

  def redis_token
    Digest::SHA1.hexdigest(email)
  end
end
