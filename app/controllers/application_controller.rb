# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Authenticable
  include RedisClient

  def raise_exception(exception)
    raise exception
  rescue exception.class => e
    handle_exceptions(e)
  end

  def handle_exceptions(exception)
    case exception
    when Api::V1::Error
      render_errors(exception.errors)
    else
      internal_server_error = Api::V1::InternalServerError.new(exception)
      Rails.logger.error { "Internal Server Error: #{exception.message} #{exception.backtrace.join("\n")}" }
      render_errors(internal_server_error.errors)
    end
  end

  def render_errors(errors)
    render json: { errors: errors }, status: errors.first.code
  end
end
