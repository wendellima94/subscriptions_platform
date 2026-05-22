require "rails_helper"

RSpec.describe "Subscription page", type: :request do
  describe "GET /subscription" do
    it "redirects unauthenticated users to login" do
      get subscription_path

      expect(response).to redirect_to(login_path)
    end

    it "shows the authenticated user's active subscription" do
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

      Subscriptions::Activate.call(user: user, plan: plan)

      post login_path, params: {
        email: user.email,
        password: "password123"
      }

      get subscription_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Minha assinatura")
      expect(response.body).to include("Profissional")
      expect(response.body).to include("Invoices")
    end
  end

  describe "DELETE /subscription" do
    it "cancels the authenticated user's active subscription" do
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

      post login_path, params: {
        email: user.email,
        password: "password123"
      }

      delete subscription_path

      expect(response).to redirect_to(subscription_path)
      expect(subscription.reload).to be_canceled
      expect(subscription.canceled_at).to be_present
    end
  end
end
