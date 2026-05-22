module Admin
  class SubscriptionsController < ApplicationController
    before_action :require_authentication
    before_action :require_admin

    def index
      @status = params[:status]

      @subscriptions = Subscription
        .includes(:user, :plan)
        .order(created_at: :desc)

      @subscriptions = @subscriptions.public_send(@status) if valid_status_filter?
    end

    private

    def valid_status_filter?
      @status.present? && Subscription.statuses.key?(@status)
    end
  end
end
