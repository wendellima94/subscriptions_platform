module Billing
  class GenerateMonthlyInvoices
    def self.call(reference_date: Date.current)
      new(reference_date).call
    end

    def initialize(reference_date)
      @reference_date = reference_date
    end

    def call
      Subscription.active.find_each do |subscription|
        Invoices::GenerateForSubscription.call(
          subscription: subscription,
          reference_date: reference_date
        )
      end
    end

    private

    attr_reader :reference_date
  end
end
