# frozen_string_literal: true

# This module contains redis related logic for API requests
module RedisClient
  def member_from_redis(token)
    redis_client.get(token)
  end

  def redis_set(member)
    redis_client.set(member.redis_token, member)
  end

  def redis_unset(token)
    redis_client.del(token)
  end

  private

  def redis_client
    Redis.new
  end
end
