class InvoicesController < ApplicationController
  before_action :require_authentication

  def pay
    invoice = current_user.invoices.find(params[:id])

    Invoices::Pay.call(invoice: invoice)

    redirect_to subscription_path, notice: "Invoice paga com sucesso."
  rescue ActiveRecord::RecordNotFound
    redirect_to subscription_path, alert: "Invoice não encontrada."
  end
end
