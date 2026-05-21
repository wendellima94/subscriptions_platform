class GenerateMonthlyInvoicesJob < ApplicationJob
  queue_as :default

  def perform(reference_date = Date.current)
    Billing::GenerateMonthlyInvoices.call(reference_date: reference_date)
  end
end
