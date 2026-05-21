require "rails_helper"

RSpec.describe "Api::V1::Subscriptions", type: :request do
  describe "POST /api/v1/subscriptions" do
    it "creates an active subscription for the authenticated user" do
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

      headers = {
        "Authorization" => "Bearer #{user.api_token}"
      }

      post "/api/v1/subscriptions",
           params: { plan_id: plan.id },
           headers: headers

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)

      expect(body["status"]).to eq("active")
      expect(body["plan"]["id"]).to eq(plan.id)

      subscription = user.subscriptions.active.first

      expect(subscription).to be_present
      expect(subscription.invoices.count).to eq(1)
      expect(subscription.invoices.first.amount_cents).to eq(5990)
    end

    it "returns unauthorized without token" do
      plan = Plan.create!(
        name: "Profissional",
        periodicity: :monthly,
        price_cents: 5990,
        active: true
      )

      post "/api/v1/subscriptions", params: { plan_id: plan.id }

      expect(response).to have_http_status(:unauthorized)

      body = JSON.parse(response.body)

      expect(body["error"]).to eq("Unauthorized")
    end
  end
end
