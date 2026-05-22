require "rails_helper"

RSpec.describe "Plans", type: :request do
  describe "GET /plans" do
    it "redirects unauthenticated users to login" do
      get plans_path

      expect(response).to redirect_to(login_path)
    end

    it "returns success for authenticated users" do
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

      get plans_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Planos disponíveis")
    end
  end
end
