# frozen_string_literal: true

module V1
  class CarsController < ApplicationController
    def index
      user = User.find(params[:user_id])
      cars = Cars::SearchService.new(user, params).call
      render json: CarBlueprint.render(cars)
    end
  end
end
