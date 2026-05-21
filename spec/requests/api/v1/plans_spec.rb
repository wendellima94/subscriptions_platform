require "rails_helper"

RSpec.describe "Api::V1::Plans", type: :request do
  describe "GET /api/v1/plans" do
    it "returns only active plans" do
      active_plan = Plan.create!(
        name: "Profissional",
        periodicity: :monthly,
        price_cents: 5990,
        active: true
      )

      Plan.create!(
        name: "Inativo",
        periodicity: :monthly,
        price_cents: 1990,
        active: false
      )

      get "/api/v1/plans"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body.size).to eq(1)
      expect(body.first["id"]).to eq(active_plan.id)
      expect(body.first["name"]).to eq("Profissional")
      expect(body.first["periodicity"]).to eq("monthly")
      expect(body.first["price_cents"]).to eq(5990)
      expect(body.first["active"]).to eq(true)
    end
  end
end
