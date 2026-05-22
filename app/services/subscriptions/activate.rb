module Subscriptions
  class Activate
    def self.call(user:, plan:)
      new(user, plan).call
    end

    def initialize(user, plan)
      @user = user
      @plan = plan
    end

    def call
      raise InactivePlanError, "plan is inactive" unless plan.active?

      ActiveRecord::Base.transaction do
        subscription = Subscription.create!(
          user: user,
          plan: plan,
          status: :active,
          started_at: Time.current
        )

        Invoices::GenerateForSubscription.call(subscription: subscription)

        subscription
      end
    end

    private

    attr_reader :user, :plan
  end
end
