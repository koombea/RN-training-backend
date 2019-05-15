# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < ApplicationController
      def create
        if member_registered?
          @member.generate_session_token
          sign_in(@member)
          render json: @member.session
        else
          raise_exception(Api::V1::ValidationErrors.new(@member))
        end
      end

      private

      def member_registered?
        @member = Member.new(member_params)
        @member.save
      end

      def member_params
        params.require(:member).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
