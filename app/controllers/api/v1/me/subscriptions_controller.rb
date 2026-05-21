module Api
  module V1
    module Me
      class SubscriptionsController < BaseController
        before_action :authenticate_user!

        def show
          subscription = current_user.subscriptions.active.includes(:plan, :invoices).first

          return render json: { subscription: nil }, status: :ok unless subscription

          render json: {
            id: subscription.id,
            status: subscription.status,
            started_at: subscription.started_at,
            canceled_at: subscription.canceled_at,
            plan: {
              id: subscription.plan.id,
              name: subscription.plan.name,
              price_cents: subscription.plan.price_cents,
              periodicity: subscription.plan.periodicity
            },
            invoices: subscription.invoices.order(reference_month: :desc).limit(5).map do |invoice|
              {
                id: invoice.id,
                reference_month: invoice.reference_month,
                amount_cents: invoice.amount_cents,
                due_on: invoice.due_on,
                paid_at: invoice.paid_at,
                status: invoice.status
              }
            end
          }, status: :ok
        end
      end
    end
  end
end
