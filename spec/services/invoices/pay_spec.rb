require "rails_helper"

RSpec.describe Invoices::Pay do
  describe ".call" do
    it "marks an open invoice as paid" do
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

      invoice = Invoice.create!(
        subscription: subscription,
        reference_month: Date.new(2026, 6, 1),
        amount_cents: 5990,
        due_on: Date.new(2026, 6, 6),
        status: :open
      )

      described_class.call(invoice: invoice)

      invoice.reload

      expect(invoice).to be_paid
      expect(invoice.paid_at).to be_present
    end

    it "does not change paid_at when invoice is already paid" do
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

      paid_at = 2.days.ago

      invoice = Invoice.create!(
        subscription: subscription,
        reference_month: Date.new(2026, 6, 1),
        amount_cents: 5990,
        due_on: Date.new(2026, 6, 6),
        status: :paid,
        paid_at: paid_at
      )

      described_class.call(invoice: invoice)

      expect(invoice.reload.paid_at.to_i).to eq(paid_at.to_i)
    end

    it "allows paying the oldest open invoice" do
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

      oldest_invoice = Invoice.create!(
        subscription: subscription,
        reference_month: Date.new(2026, 5, 1),
        amount_cents: 5990,
        due_on: Date.new(2026, 5, 6),
        status: :open
      )

      Invoice.create!(
        subscription: subscription,
        reference_month: Date.new(2026, 6, 1),
        amount_cents: 5990,
        due_on: Date.new(2026, 6, 6),
        status: :open
      )

      described_class.call(invoice: oldest_invoice)

      expect(oldest_invoice.reload).to be_paid
    end

    it "does not allow paying a future invoice when older open invoices exist" do
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

      future_invoice = Invoice.create!(
        subscription: subscription,
        reference_month: Date.new(2026, 6, 1),
        amount_cents: 5990,
        due_on: Date.new(2026, 6, 6),
        status: :open
      )

      expect {
        described_class.call(invoice: future_invoice)
      }.to raise_error(Invoices::PaymentOutOfOrderError)

      expect(future_invoice.reload).to be_open
      expect(future_invoice.paid_at).to be_nil
    end
  end
end
