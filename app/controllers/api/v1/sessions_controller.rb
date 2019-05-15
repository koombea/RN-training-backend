# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      before_action :authenticate_request!, only: [:destroy]

      def create
        if authentication_succeeds?
          member.generate_session_token
          sign_in(member)
          render json: member.session
        else
          raise_exception(Api::V1::Unauthorized.new(nil))
        end
      end

      def destroy
        sign_out
        head :ok
      end

      private

      def authentication_succeeds?
        member&.valid_password?(credentials[:password])
      end

      def member
        @member ||= Member.find_by(email: credentials[:email])
      end

      def credentials
        params.require(:session).permit(:email, :password)
      end
    end
  end
end
