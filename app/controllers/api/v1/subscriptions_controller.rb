module Api
  module V1
    class SubscriptionsController < BaseController
      before_action :authenticate_user!

      def create
        plan = Plan.find(params[:plan_id])

        subscription = Subscriptions::Activate.call(
          user: current_user,
          plan: plan
        )

        render json: {
          id: subscription.id,
          status: subscription.status,
          started_at: subscription.started_at,
          plan: {
            id: subscription.plan.id,
            name: subscription.plan.name,
            price_cents: subscription.plan.price_cents,
            periodicity: subscription.plan.periodicity
          }
        }, status: :created
      rescue Subscriptions::InactivePlanError
        render json: { error: "Plan is inactive" }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => error
        render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Plan not found" }, status: :not_found
      end
    end
  end
end
