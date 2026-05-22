module Invoices
  class GenerateNextForSubscription
    def self.call(subscription:)
      new(subscription).call
    end

    def initialize(subscription)
      @subscription = subscription
    end

    def call
      raise ActiveRecord::RecordInvalid, subscription unless subscription.active?

      Invoices::GenerateForSubscription.call(
        subscription: subscription,
        reference_date: next_reference_month
      )
    end

    private

    attr_reader :subscription

    def next_reference_month
      last_reference_month = subscription
        .invoices
        .maximum(:reference_month)

      return Date.current.beginning_of_month if last_reference_month.blank?

      last_reference_month.next_month.beginning_of_month
    end
  end
end
