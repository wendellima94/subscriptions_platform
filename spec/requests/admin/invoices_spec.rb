require "rails_helper"

RSpec.describe "Admin::Invoices", type: :request do
  describe "GET /admin/invoices" do
    it "redirects unauthenticated users to login" do
      get admin_invoices_path

      expect(response).to redirect_to(login_path)
    end

    it "does not allow customer users" do
      customer = User.create!(
        name: "Customer",
        email: "customer@example.com",
        password: "password123",
        role: :customer
      )

      post login_path, params: {
        email: customer.email,
        password: "password123"
      }

      get admin_invoices_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Você não tem permissão para acessar essa área.")
    end

    it "allows admin users to access invoices list" do
      admin = User.create!(
        name: "Admin",
        email: "admin@example.com",
        password: "password123",
        role: :admin
      )

      customer = User.create!(
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

      Subscriptions::Activate.call(user: customer, plan: plan)

      post login_path, params: {
        email: admin.email,
        password: "password123"
      }

      get admin_invoices_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Invoices")
      expect(response.body).to include("Customer")
      expect(response.body).to include("Profissional")
      expect(response.body).to include("open")
    end

    it "filters invoices by status" do
      admin = User.create!(
        name: "Admin",
        email: "admin@example.com",
        password: "password123",
        role: :admin
      )

      customer = User.create!(
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

      subscription = Subscriptions::Activate.call(user: customer, plan: plan)
      invoice = subscription.invoices.first

      Invoices::Pay.call(invoice: invoice)

      Invoice.create!(
        subscription: subscription,
        reference_month: Date.current.next_month.beginning_of_month,
        amount_cents: 5990,
        due_on: Date.current.next_month.beginning_of_month + 5.days,
        status: :open
      )

      post login_path, params: {
        email: admin.email,
        password: "password123"
      }

      get admin_invoices_path(status: "paid")

      expect(response).to have_http_status(:success)
      expect(response.body).to include("paid")
      expect(response.body).not_to include(">open<")
    end

    it "filters invoices by reference month" do
      admin = User.create!(
        name: "Admin",
        email: "admin@example.com",
        password: "password123",
        role: :admin
      )

      customer = User.create!(
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

      subscription = Subscriptions::Activate.call(user: customer, plan: plan)

      current_invoice = subscription.invoices.first
      current_invoice.update!(reference_month: Date.new(2026, 5, 1))

      Invoice.create!(
        subscription: subscription,
        reference_month: Date.new(2026, 6, 1),
        amount_cents: 5990,
        due_on: Date.new(2026, 6, 6),
        status: :open
      )

      post login_path, params: {
        email: admin.email,
        password: "password123"
      }


      get admin_invoices_path(reference_month: "2026-05")

      expect(response).to have_http_status(:success)
      expect(response.body).to include("2026-05-27")
      expect(response.body).not_to include("2026-06-06")
    end
  end
end
