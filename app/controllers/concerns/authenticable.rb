# frozen_string_literal: true

# This module contains authentication logic for API requests
module Authenticable
  def authenticate_request!
    return if current_member.present?

    raise_exception(Api::V1::Unauthorized.new(nil))
  end

  def current_member
    @current_member ||= authenticate
  end

  def sign_in(member)
    redis_set(member)
  end

  def sign_out
    redis_unset(payload[0]['token'])
  end

  def authenticate
    return nil if !payload || !JsonWebToken.valid_payload(payload.first)

    member_from_redis(payload[0]['token'])
  end

  private

  def payload
    auth_header = request.headers['Authorization']
    token = auth_header.split(' ').last
    JsonWebToken.decode(token)
  rescue StandardError
    nil
  end
end
