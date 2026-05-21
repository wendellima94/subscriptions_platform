require "rails_helper"

RSpec.describe Subscription, type: :model do
  describe "validations" do
    it "does not allow more than one active subscription for the same user" do
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

      Subscription.create!(
        user: user,
        plan: plan,
        status: :active,
        started_at: Time.current
      )

      second_subscription = Subscription.new(
        user: user,
        plan: plan,
        status: :active,
        started_at: Time.current
      )

      expect(second_subscription).not_to be_valid
      expect(second_subscription.errors[:base]).to include("user already has an active subscription")
    end
  end
end
