module Api
  module V1
    class InvoicesController < BaseController
      before_action :authenticate_user!

      def pay
        invoice = current_user.invoices.find(params[:id])

        Invoices::Pay.call(invoice: invoice)

         render json: {
          id: invoice.id,
          status: invoice.reload.status,
          paid_at: invoice.paid_at
        }, status: :ok
      rescue Invoices::PaymentOutOfOrderError
        render json: {
          error: "Pay older open invoices first"
        }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Invoice not found" }, status: :not_found
      end
    end
  end
end
