module Admin
  class SubscriptionsController < BaseController
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
