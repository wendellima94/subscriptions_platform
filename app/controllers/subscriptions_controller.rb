class SubscriptionsController < ApplicationController
  before_action :require_authentication

  def create
    plan = Plan.active.find(params[:plan_id])

    Subscriptions::Activate.call(
      user: current_user,
      plan: plan
    )

    redirect_to plans_path, notice: "Assinatura ativada com sucesso."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to plans_path, alert: error.record.errors.full_messages.to_sentence
  rescue ActiveRecord::RecordNotFound
    redirect_to plans_path, alert: "Plano não encontrado."
  end
end
