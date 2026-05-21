require "rails_helper"

RSpec.describe "Api::V1::Me::Subscription", type: :request do
  describe "GET /api/v1/me/subscription" do
    it "returns the authenticated user's active subscription" do
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

      headers = {
        "Authorization" => "Bearer #{user.api_token}"
      }

      get "/api/v1/me/subscription", headers: headers

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["id"]).to eq(subscription.id)
      expect(body["status"]).to eq("active")
      expect(body["plan"]["id"]).to eq(plan.id)
      expect(body["invoices"]).not_to be_empty
    end

    it "returns unauthorized without token" do
      get "/api/v1/me/subscription"

      expect(response).to have_http_status(:unauthorized)

      body = JSON.parse(response.body)

      expect(body["error"]).to eq("Unauthorized")
    end
  end
end
