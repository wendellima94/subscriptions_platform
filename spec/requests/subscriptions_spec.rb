require "rails_helper"

RSpec.describe "Subscriptions", type: :request do
  describe "POST /subscriptions" do
    it "redirects unauthenticated users to login" do
      plan = Plan.create!(
        name: "Profissional",
        periodicity: :monthly,
        price_cents: 5990,
        active: true
      )

      post subscriptions_path, params: { plan_id: plan.id }

      expect(response).to redirect_to(login_path)
    end

    it "creates a subscription for authenticated users" do
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

      post login_path, params: {
        email: user.email,
        password: "password123"
      }

      post subscriptions_path, params: { plan_id: plan.id }

      expect(response).to redirect_to(plans_path)
      expect(flash[:notice]).to eq("Assinatura ativada com sucesso.")

      subscription = user.subscriptions.active.first

      expect(subscription).to be_present
      expect(subscription.plan).to eq(plan)
      expect(subscription.invoices.count).to eq(1)
    end
  end
end
