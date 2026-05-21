module Api
  module V1
    class PlansController < ApplicationController
      def index
        plans = Plan.active.order(:price_cents)

        render json: plans.as_json(
          only: [
            :id,
            :name,
            :periodicity,
            :price_cents,
            :active
          ]
        )
      end
    end
  end
end
