require "rails_helper"

RSpec.describe Invoice, type: :model do
  it "is valid with valid attributes" do
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

    subscription = Subscription.create!(
      user: user,
      plan: plan,
      status: :active,
      started_at: Time.current
    )

    invoice = Invoice.new(
      subscription: subscription,
      reference_month: Date.current.beginning_of_month,
      amount_cents: 5990,
      due_on: 5.days.from_now.to_date,
      status: :open
    )

    expect(invoice).to be_valid
  end

  it "is invalid without a positive amount" do
    invoice = Invoice.new(amount_cents: 0)

    expect(invoice).not_to be_valid
  end
end
