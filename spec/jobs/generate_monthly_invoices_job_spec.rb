require "rails_helper"

RSpec.describe GenerateMonthlyInvoicesJob, type: :job do
  it "calls the monthly invoice generation service" do
    reference_date = Date.new(2026, 8, 1)

    expect(Billing::GenerateMonthlyInvoices).to receive(:call).with(
      reference_date: reference_date
    )

    described_class.perform_now(reference_date)
  end
end
