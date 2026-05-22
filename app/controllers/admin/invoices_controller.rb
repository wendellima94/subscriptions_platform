module Admin
  class InvoicesController < BaseController
    def index
      @status = params[:status]
      @reference_month = params[:reference_month]

      @invoices = Invoice
        .includes(subscription: [ :user, :plan ])
        .order(reference_month: :desc, created_at: :desc)

      @invoices = @invoices.public_send(@status) if valid_status_filter?
      @invoices = @invoices.where(reference_month: parsed_reference_month) if parsed_reference_month.present?
    end

    private

    def valid_status_filter?
      @status.present? && Invoice.statuses.key?(@status)
    end

    def parsed_reference_month
      return if @reference_month.blank?

      Date.strptime("#{@reference_month}-01", "%Y-%m-%d").beginning_of_month
    rescue Date::Error
      nil
    end
  end
end
