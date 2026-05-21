require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = User.new(
      name: "Customer",
      email: "customer@example.com",
      password: "password123",
      role: :customer
    )

    expect(user).to be_valid
  end

  it "does not allow duplicated emails" do
    User.create!(
      name: "Customer",
      email: "customer@example.com",
      password: "password123",
      role: :customer
    )

    duplicated_user = User.new(
      name: "Another Customer",
      email: "customer@example.com",
      password: "password123",
      role: :customer
    )

    expect(duplicated_user).not_to be_valid
  end
end
