class SubscriptionsController < ApplicationController
  before_action :require_authentication

  def create
    plan = Plan.active.find(params[:plan_id])

    Subscriptions::Activate.call(
      user: current_user,
      plan: plan
    )

    redirect_to subscription_path, notice: "Assinatura ativada com sucesso."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to plans_path, alert: error.record.errors.full_messages.to_sentence
  rescue ActiveRecord::RecordNotFound
    redirect_to plans_path, alert: "Plano não encontrado."
  end

  def show
    @subscription = current_user.subscriptions.active.includes(:plan, :invoices).first
    @invoices = @subscription&.invoices&.order(reference_month: :desc) || []
  end

  def destroy
    subscription = current_user.subscriptions.active.first

    return redirect_to subscription_path, alert: "Nenhuma assinatura ativa encontrada." unless subscription

    Subscriptions::Cancel.call(subscription: subscription)

    redirect_to subscription_path, notice: "Assinatura cancelada com sucesso."
  end
  def generate_next_invoice
    subscription = current_user.subscriptions.active.first

    return redirect_to subscription_path, alert: "Nenhuma assinatura ativa encontrada." unless subscription

    Invoices::GenerateNextForSubscription.call(subscription: subscription)

    redirect_to subscription_path, notice: "Próxima invoice gerada com sucesso."
  rescue ActiveRecord::RecordInvalid
    redirect_to subscription_path, alert: "Não foi possível gerar a próxima invoice."
  end
end
