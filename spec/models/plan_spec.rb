require "rails_helper"

RSpec.describe Plan, type: :model do
  it "is valid with valid attributes" do
    plan = Plan.new(
      name: "Profissional",
      periodicity: :monthly,
      price_cents: 5990,
      active: true
    )

    expect(plan).to be_valid
  end

  it "is invalid without a positive price" do
    plan = Plan.new(
      name: "Profissional",
      periodicity: :monthly,
      price_cents: 0,
      active: true
    )

    expect(plan).not_to be_valid
  end
end
