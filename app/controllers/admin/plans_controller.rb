module Admin
  class PlansController < ApplicationController
    before_action :require_authentication
    before_action :require_admin
    before_action :set_plan, only: [ :edit, :update, :destroy ]

    def index
      @plans = Plan.order(:price_cents)
    end

    def new
      @plan = Plan.new
    end

    def create
      @plan = Plan.new(plan_params)

      if @plan.save
        redirect_to admin_plans_path, notice: "Plano criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @plan.update(plan_params)
        redirect_to admin_plans_path, notice: "Plano atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @plan.destroy
        redirect_to admin_plans_path, notice: "Plano removido com sucesso."
      else
        redirect_to admin_plans_path, alert: "Não é possível remover um plano que possui assinaturas."
      end
    end

    private

    def set_plan
      @plan = Plan.find(params[:id])
    end

    def plan_params
      params.require(:plan).permit(
        :name,
        :periodicity,
        :price_cents,
        :active
      )
    end
  end
end
