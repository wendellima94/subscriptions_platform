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

      post api_v1_subscriptions_path,
           params: { plan_id: plan.id },
           headers: { "Authorization" => "Bearer #{user.api_token}" }

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)

      expect(body["status"]).to eq("active")
      expect(body["plan"]["id"]).to eq(plan.id)

      subscription = user.subscriptions.active.first

      expect(subscription).to be_present
      expect(subscription.invoices.count).to eq(1)
      expect(subscription.invoices.first.amount_cents).to eq(5990)
    end

    it "returns unprocessable entity when plan is inactive" do
      user = User.create!(
        name: "Customer",
        email: "customer@example.com",
        password: "password123",
        role: :customer
      )

      inactive_plan = Plan.create!(
        name: "Plano antigo",
        periodicity: :monthly,
        price_cents: 2990,
        active: false
      )

      post api_v1_subscriptions_path,
           params: { plan_id: inactive_plan.id },
           headers: { "Authorization" => "Bearer #{user.api_token}" }

      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)

      expect(body["error"]).to eq("Plan is inactive")
      expect(user.subscriptions.count).to eq(0)
    end

    it "returns unauthorized without token" do
      plan = Plan.create!(
        name: "Profissional",
        periodicity: :monthly,
        price_cents: 5990,
        active: true
      )

      post api_v1_subscriptions_path, params: { plan_id: plan.id }

      expect(response).to have_http_status(:unauthorized)

      body = JSON.parse(response.body)

      expect(body["error"]).to eq("Unauthorized")
    end
  end
end
