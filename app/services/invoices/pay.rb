module Invoices
  class Pay
    def self.call(invoice:)
      new(invoice).call
    end

    def initialize(invoice)
      @invoice = invoice
    end

    def call
      return invoice if invoice.paid?

      invoice.update!(
        status: :paid,
        paid_at: Time.current
      )

      invoice
    end

    private

    attr_reader :invoice
  end
end
