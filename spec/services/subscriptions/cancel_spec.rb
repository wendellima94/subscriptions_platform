require "rails_helper"

RSpec.describe Subscriptions::Cancel do
  describe ".call" do
    it "marks an active subscription as canceled" do
      user = User.create!(
        name: "Customer",
        email: "customer@example.com",
        password: "password123",
        role: :customer
      )

      plan = Plan.create!(
        name: "Profissional",
        periodicity: :monthly,
        price_cents: 5990,
        active: true
      )

      subscription = Subscription.create!(
        user: user,
        plan: plan,
        status: :active,
        started_at: Time.current
      )

      described_class.call(subscription: subscription)

      subscription.reload

      expect(subscription).to be_canceled
      expect(subscription.canceled_at).to be_present
    end

    it "does not change canceled_at when subscription is already canceled" do
      user = User.create!(
        name: "Customer",
        email: "customer@example.com",
        password: "password123",
        role: :customer
      )

      plan = Plan.create!(
        name: "Profissional",
        periodicity: :monthly,
        price_cents: 5990,
        active: true
      )

      canceled_at = 2.days.ago

      subscription = Subscription.create!(
        user: user,
        plan: plan,
        status: :canceled,
        started_at: 1.month.ago,
        canceled_at: canceled_at
      )

      described_class.call(subscription: subscription)

      expect(subscription.reload.canceled_at.to_i).to eq(canceled_at.to_i)
    end
  end
end
