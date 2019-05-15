# frozen_string_literal: true

class JsonWebToken
  class << self
    def encode(payload)
      payload.reverse_merge!(meta)
      JWT.encode(payload, ENV.fetch('SECRET_KEY_BASE'))
    end

    def decode(token)
      JWT.decode(token, ENV.fetch('SECRET_KEY_BASE'))
    end

    def valid_payload(payload)
      if expired(payload) || payload['iss'] != meta[:iss] || payload['aud'] != meta[:aud]
        false
      else
        true
      end
    end

    def meta
      {
        exp: 1.days.from_now.to_i,
        iss: 'issuer_name',
        aud: 'client'
      }
    end

    def expired(payload)
      Time.at(payload['exp']) < Time.now
    end
  end
end
