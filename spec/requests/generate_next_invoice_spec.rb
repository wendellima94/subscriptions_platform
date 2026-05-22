require "rails_helper"

RSpec.describe "Generate next invoice", type: :request do
  describe "POST /subscription/generate_next_invoice" do
    it "redirects unauthenticated users to login" do
      post generate_next_invoice_subscription_path

      expect(response).to redirect_to(login_path)
    end

    it "generates the next invoice for the authenticated user's active subscription" do
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

      first_invoice = subscription.invoices.first
      first_invoice.update!(
        reference_month: Date.new(2026, 5, 1),
        due_on: Date.new(2026, 5, 6)
      )

      post login_path, params: {
        email: user.email,
        password: "password123"
      }

      expect {
        post generate_next_invoice_subscription_path
      }.to change(Invoice, :count).by(1)

      expect(response).to redirect_to(subscription_path)
      expect(flash[:notice]).to eq("Próxima invoice gerada com sucesso.")

      next_invoice = subscription.invoices.order(:reference_month).last

      expect(next_invoice.reference_month).to eq(Date.new(2026, 6, 1))
      expect(next_invoice).to be_open
    end

    it "does not generate an invoice when authenticated user has no active subscription" do
      user = User.create!(
        name: "Customer",
        email: "customer@example.com",
        password: "password123",
        role: :customer
      )

      post login_path, params: {
        email: user.email,
        password: "password123"
      }

      expect {
        post generate_next_invoice_subscription_path
      }.not_to change(Invoice, :count)

      expect(response).to redirect_to(subscription_path)
      expect(flash[:alert]).to eq("Nenhuma assinatura ativa encontrada.")
    end
  end
end
