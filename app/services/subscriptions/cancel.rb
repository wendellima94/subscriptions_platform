module Subscriptions
  class Cancel
    def self.call(subscription:)
      new(subscription).call
    end

    def initialize(subscription)
      @subscription = subscription
    end

    def call
      return subscription if subscription.canceled?

      subscription.update!(
        status: :canceled,
        canceled_at: Time.current
      )

      subscription
    end

    private

    attr_reader :subscription
  end
end
