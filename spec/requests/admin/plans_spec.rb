require "rails_helper"

RSpec.describe "Admin::Plans", type: :request do
  describe "GET /admin/plans" do
    it "redirects unauthenticated users to login" do
      get admin_plans_path

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

      get admin_plans_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Você não tem permissão para acessar essa área.")
    end

    it "allows admin users to access the plans list" do
      admin = User.create!(
        name: "Admin",
        email: "admin@example.com",
        password: "password123",
        role: :admin
      )

      Plan.create!(
        name: "Profissional",
        periodicity: :monthly,
        price_cents: 5990,
        active: true
      )

      post login_path, params: {
        email: admin.email,
        password: "password123"
      }

      get admin_plans_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Planos")
      expect(response.body).to include("Profissional")
    end
  end

  describe "POST /admin/plans" do
    it "allows admin users to create a plan" do
      admin = User.create!(
        name: "Admin",
        email: "admin@example.com",
        password: "password123",
        role: :admin
      )

      post login_path, params: {
        email: admin.email,
        password: "password123"
      }

      expect {
        post admin_plans_path, params: {
          plan: {
            name: "Enterprise",
            periodicity: "quarterly",
            price_cents: 19990,
            active: true
          }
        }
      }.to change(Plan, :count).by(1)

      expect(response).to redirect_to(admin_plans_path)

      plan = Plan.last

      expect(plan.name).to eq("Enterprise")
      expect(plan.periodicity).to eq("quarterly")
      expect(plan.price_cents).to eq(19990)
      expect(plan.active).to be(true)
    end
  end

  describe "PATCH /admin/plans/:id" do
    it "allows admin users to update a plan" do
      admin = User.create!(
        name: "Admin",
        email: "admin@example.com",
        password: "password123",
        role: :admin
      )

      plan = Plan.create!(
        name: "Basic",
        periodicity: :monthly,
        price_cents: 2990,
        active: true
      )

      post login_path, params: {
        email: admin.email,
        password: "password123"
      }

      patch admin_plan_path(plan), params: {
        plan: {
          name: "Basic Updated",
          periodicity: "monthly",
          price_cents: 3990,
          active: false
        }
      }

      expect(response).to redirect_to(admin_plans_path)

      plan.reload

      expect(plan.name).to eq("Basic Updated")
      expect(plan.price_cents).to eq(3990)
      expect(plan.active).to be(false)
    end
  end

  describe "DELETE /admin/plans/:id" do
    it "allows admin users to remove a plan without subscriptions" do
      admin = User.create!(
        name: "Admin",
        email: "admin@example.com",
        password: "password123",
        role: :admin
      )

      plan = Plan.create!(
        name: "Basic",
        periodicity: :monthly,
        price_cents: 2990,
        active: true
      )

      post login_path, params: {
        email: admin.email,
        password: "password123"
      }

      expect {
        delete admin_plan_path(plan)
      }.to change(Plan, :count).by(-1)

      expect(response).to redirect_to(admin_plans_path)
      expect(flash[:notice]).to eq("Plano removido com sucesso.")
    end

    it "does not remove a plan with subscriptions" do
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

      expect {
        delete admin_plan_path(plan)
      }.not_to change(Plan, :count)

      expect(response).to redirect_to(admin_plans_path)
      expect(flash[:alert]).to eq("Não é possível remover um plano que possui assinaturas.")
    end
  end
end
