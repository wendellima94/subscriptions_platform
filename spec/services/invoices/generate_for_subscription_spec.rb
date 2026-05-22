require "rails_helper"

RSpec.describe Invoices::GenerateForSubscription do
  describe ".call" do
    it "creates an invoice for the given subscription" do
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

      invoice = described_class.call(
        subscription: subscription,
        reference_date: Date.new(2026, 6, 1)
      )

      expect(invoice).to be_persisted
      expect(invoice.subscription).to eq(subscription)
      expect(invoice.reference_month).to eq(Date.new(2026, 6, 1))
      expect(invoice.amount_cents).to eq(5990)
      expect(invoice.due_on).to eq(Date.new(2026, 6, 6))
      expect(invoice.status).to eq("open")
    end

    it "does not create a duplicated invoice for the same month" do
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

      first_invoice = described_class.call(
        subscription: subscription,
        reference_date: Date.new(2026, 6, 1)
      )

      expect {
        second_invoice = described_class.call(
          subscription: subscription,
          reference_date: Date.new(2026, 6, 1)
        )

        expect(second_invoice).to eq(first_invoice)
      }.not_to change(Invoice, :count)
    end

    it "keeps the plan price at the moment of invoice generation" do
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

      invoice = described_class.call(
        subscription: subscription,
        reference_date: Date.new(2026, 6, 1)
      )

      plan.update!(price_cents: 7990)

      expect(invoice.reload.amount_cents).to eq(5990)
      expect(plan.reload.price_cents).to eq(7990)
    end
  end
end
