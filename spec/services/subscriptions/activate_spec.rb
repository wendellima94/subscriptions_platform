require "rails_helper"

RSpec.describe Subscriptions::Activate do
  describe ".call" do
    it "creates an active subscription and the first invoice" do
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

      subscription = described_class.call(user: user, plan: plan)

      expect(subscription).to be_persisted
      expect(subscription).to be_active
      expect(subscription.started_at).to be_present
      expect(subscription.plan).to eq(plan)
      expect(subscription.user).to eq(user)

      invoice = subscription.invoices.first

      expect(invoice).to be_present
      expect(invoice).to be_open
      expect(invoice.amount_cents).to eq(5990)
      expect(invoice.reference_month).to eq(Date.current.beginning_of_month)
      expect(invoice.due_on).to eq(5.days.from_now.to_date)
    end
  end
end
