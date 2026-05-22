require "rails_helper"

RSpec.describe Billing::GenerateMonthlyInvoices do
  describe ".call" do
    it "generates an invoice for active subscriptions" do
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

      expect {
        described_class.call(reference_date: Date.new(2026, 6, 1))
      }.to change(Invoice, :count).by(1)

      invoice = subscription.invoices.last

      expect(invoice.reference_month).to eq(Date.new(2026, 6, 1))
      expect(invoice.amount_cents).to eq(5990)
      expect(invoice.due_on).to eq(Date.new(2026, 6, 6))
      expect(invoice.status).to eq("open")
    end

    it "does not generate an invoice for canceled subscriptions" do
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
        status: :canceled,
        started_at: 1.month.ago,
        canceled_at: Time.current
      )

      expect {
        described_class.call(reference_date: Date.new(2026, 6, 1))
      }.not_to change(Invoice, :count)
    end

    it "does not duplicate invoices for the same subscription and reference month" do
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

      described_class.call(reference_date: Date.new(2026, 6, 1))

      expect {
        described_class.call(reference_date: Date.new(2026, 6, 1))
      }.not_to change(Invoice, :count)

      expect(
        subscription.invoices.where(reference_month: Date.new(2026, 6, 1)).count
      ).to eq(1)
    end
  end
end
