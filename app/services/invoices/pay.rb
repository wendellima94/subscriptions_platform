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

      raise PaymentOutOfOrderError, "there are older open invoices" if older_open_invoice_exists?

      invoice.update!(
        status: :paid,
        paid_at: Time.current
      )

      invoice
    end

    private

    attr_reader :invoice

    def older_open_invoice_exists?
      invoice
        .subscription
        .invoices
        .open
        .where("reference_month < ?", invoice.reference_month)
        .exists?
    end
  end
end
