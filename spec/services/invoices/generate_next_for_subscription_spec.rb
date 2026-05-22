require "rails_helper"

RSpec.describe Invoices::GenerateNextForSubscription do
  describe ".call" do
    it "generates the current month invoice when subscription has no invoices" do
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

      invoice = described_class.call(subscription: subscription)

      expect(invoice).to be_persisted
      expect(invoice.reference_month).to eq(Date.current.beginning_of_month)
      expect(invoice).to be_open
      expect(invoice.amount_cents).to eq(5990)
    end

    it "generates the next invoice after the latest reference month" do
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

      Invoice.create!(
        subscription: subscription,
        reference_month: Date.new(2026, 5, 1),
        amount_cents: 5990,
        due_on: Date.new(2026, 5, 6),
        status: :open
      )

      invoice = described_class.call(subscription: subscription)

      expect(invoice.reference_month).to eq(Date.new(2026, 6, 1))
      expect(invoice.due_on).to eq(Date.new(2026, 6, 6))
      expect(invoice.amount_cents).to eq(5990)
      expect(invoice).to be_open
    end

    it "does not generate invoices for canceled subscriptions" do
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
        status: :canceled,
        started_at: 1.month.ago,
        canceled_at: Time.current
      )

      expect {
        described_class.call(subscription: subscription)
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect(subscription.invoices.count).to eq(0)
    end

    it "does not duplicate the next reference month invoice" do
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

      Invoice.create!(
        subscription: subscription,
        reference_month: Date.new(2026, 5, 1),
        amount_cents: 5990,
        due_on: Date.new(2026, 5, 6),
        status: :open
      )

      first_generated_invoice = described_class.call(subscription: subscription)

      expect {
        Invoices::GenerateForSubscription.call(
          subscription: subscription,
          reference_date: first_generated_invoice.reference_month
        )
      }.not_to change(Invoice, :count)

      expect(
        subscription.invoices.where(reference_month: Date.new(2026, 6, 1)).count
      ).to eq(1)
    end
  end
end
