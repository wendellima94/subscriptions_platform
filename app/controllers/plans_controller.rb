class PlansController < ApplicationController
  before_action :require_authentication

  def index
    @plans = Plan.active.order(:price_cents)
    @active_subscription = current_user.subscriptions.active.first
  end
end
