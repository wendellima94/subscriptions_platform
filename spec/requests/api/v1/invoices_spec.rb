require "rails_helper"

RSpec.describe "Api::V1::Invoices", type: :request do
  describe "POST /api/v1/invoices/:id/pay" do
    it "pays an invoice that belongs to the authenticated user" do
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

      headers = {
        "Authorization" => "Bearer #{user.api_token}"
      }

      post "/api/v1/invoices/#{invoice.id}/pay", headers: headers

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["id"]).to eq(invoice.id)
      expect(body["status"]).to eq("paid")
      expect(body["paid_at"]).to be_present

      expect(invoice.reload).to be_paid
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

      headers = {
        "Authorization" => "Bearer #{another_user.api_token}"
      }

      post "/api/v1/invoices/#{invoice.id}/pay", headers: headers

      expect(response).to have_http_status(:not_found)

      body = JSON.parse(response.body)

      expect(body["error"]).to eq("Invoice not found")
      expect(invoice.reload).to be_open
    end
  end
end
