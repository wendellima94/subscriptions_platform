module Invoices
  class GenerateForSubscription
    def self.call(subscription:, reference_date: Date.current)
      new(subscription, reference_date).call
    end

    def initialize(subscription, reference_date)
      @subscription = subscription
      @reference_date = reference_date
    end

    def call
      Invoice.create!(
        subscription: subscription,
        reference_month: reference_month,
        amount_cents: subscription.plan.price_cents,
        due_on: due_on,
        status: :open
      )
    end

    private

    attr_reader :subscription, :reference_date

    def reference_month
      reference_date.beginning_of_month
    end

    def due_on
      reference_date == Date.current ? 5.days.from_now.to_date : reference_month + 5.days
    end
  end
end
