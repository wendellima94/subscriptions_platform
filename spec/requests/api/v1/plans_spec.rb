require "rails_helper"

RSpec.describe "Api::V1::Plans", type: :request do
  describe "GET /api/v1/plans" do
    it "returns only active plans ordered by price" do
      inactive_plan = Plan.create!(
        name: "Inativo",
        periodicity: :monthly,
        price_cents: 1990,
        active: false
      )

      basic_plan = Plan.create!(
        name: "Básico",
        periodicity: :monthly,
        price_cents: 2990,
        active: true
      )

      professional_plan = Plan.create!(
        name: "Profissional",
        periodicity: :monthly,
        price_cents: 5990,
        active: true
      )

      get "/api/v1/plans"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body.size).to eq(2)

      expect(body.map { |plan| plan["id"] }).to eq([
        basic_plan.id,
        professional_plan.id
      ])

      expect(body.map { |plan| plan["id"] }).not_to include(inactive_plan.id)

      expect(body.first).to include(
        "id" => basic_plan.id,
        "name" => "Básico",
        "periodicity" => "monthly",
        "price_cents" => 2990,
        "active" => true
      )
    end
  end
end
