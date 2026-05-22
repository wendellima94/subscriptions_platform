require "rails_helper"

RSpec.describe "Invoices", type: :request do
  describe "POST /invoices/:id/pay" do
    it "pays an authenticated user's oldest open invoice" do
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

      subscription = Subscriptions::Activate.call(user: user, plan: plan)
      invoice = subscription.invoices.first

      post login_path, params: {
        email: user.email,
        password: "password123"
      }

      post pay_invoice_path(invoice)

      expect(response).to redirect_to(subscription_path)
      expect(invoice.reload).to be_paid
      expect(invoice.paid_at).to be_present
    end

    it "does not allow paying another user's invoice" do
      owner = User.create!(
        name: "Owner",
        email: "owner@example.com",
        password: "password123",
        role: :customer
      )

      another_user = User.create!(
        name: "Another Customer",
        email: "another@example.com",
        password: "password123",
        role: :customer
      )

      plan = Plan.create!(
        name: "Profissional",
        periodicity: :monthly,
        price_cents: 5990,
        active: true
      )

      subscription = Subscriptions::Activate.call(user: owner, plan: plan)
      invoice = subscription.invoices.first

      post login_path, params: {
        email: another_user.email,
        password: "password123"
      }

      post pay_invoice_path(invoice)

      expect(response).to redirect_to(subscription_path)
      expect(flash[:alert]).to eq("Invoice não encontrada.")
      expect(invoice.reload).to be_open
    end

    it "does not allow paying a future invoice before older open invoices" do
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

      subscription = Subscriptions::Activate.call(user: user, plan: plan)

      older_invoice = subscription.invoices.first
      older_invoice.update!(
        reference_month: Date.new(2026, 5, 1),
        due_on: Date.new(2026, 5, 6),
        status: :open,
        paid_at: nil
      )

      future_invoice = Invoice.create!(
        subscription: subscription,
        reference_month: Date.new(2026, 6, 1),
        amount_cents: 5990,
        due_on: Date.new(2026, 6, 6),
        status: :open
      )

      post login_path, params: {
        email: user.email,
        password: "password123"
      }

      post pay_invoice_path(future_invoice)

      expect(response).to redirect_to(subscription_path)
      expect(flash[:alert]).to eq("Pague primeiro as invoices anteriores em aberto.")
      expect(older_invoice.reload).to be_open
      expect(future_invoice.reload).to be_open
    end
  end
end
