# frozen_string_literal: true

module Request
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end

    def errors
      json['errors']
    end
  end

  module HeadersHelpers
    def authenticate_member!(member)
      member.generate_session_token
      Redis.new.set(member.redis_token, member)
      request.env['HTTP_AUTHORIZATION'] = "Bearer #{member.session_token}"
    end
  end
end
