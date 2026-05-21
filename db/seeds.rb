puts "Cleaning database..."

Invoice.destroy_all
Subscription.destroy_all
Plan.destroy_all
User.destroy_all

puts "Creating users..."

admin = User.create!(
  name: "Admin",
  email: "admin@example.com",
  password: "password123",
  role: :admin
)

customer = User.create!(
  name: "Customer One",
  email: "customer@example.com",
  password: "password123",
  role: :customer
)

second_customer = User.create!(
  name: "Customer Two",
  email: "customer2@example.com",
  password: "password123",
  role: :customer
)

puts "Creating plans..."

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

enterprise_plan = Plan.create!(
  name: "Empresarial",
  periodicity: :monthly,
  price_cents: 9990,
  active: true
)

puts "Creating subscriptions..."

active_subscription = Subscriptions::Activate.call(
  user: customer,
  plan: professional_plan
)

canceled_subscription = Subscriptions::Activate.call(
  user: second_customer,
  plan: basic_plan
)

Subscriptions::Cancel.call(subscription: canceled_subscription)

puts "Creating sample invoices..."

Invoices::GenerateForSubscription.call(
  subscription: active_subscription,
  reference_date: Date.current.next_month
)

puts "Done!"

puts "Admin credentials:"
puts "Email: #{admin.email}"
puts "Password: password123"

puts "Customer credentials:"
puts "Email: #{customer.email}"
puts "Password: password123"

puts "Second customer credentials:"
puts "Email: #{second_customer.email}"
puts "Password: password123"

puts "Created:"
puts "#{User.count} users"
puts "#{Plan.count} plans"
puts "#{Subscription.count} subscriptions"
puts "#{Invoice.count} invoices"
