module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      private

      def current_user
        @current_user ||= User.find_by(api_token: bearer_token)
      end

      def authenticate_user!
        return if current_user.present?

        render json: { error: "Unauthorized" }, status: :unauthorized
      end

      def bearer_token
        request.headers["Authorization"].to_s.remove("Bearer ").strip
      end
    end
  end
end
