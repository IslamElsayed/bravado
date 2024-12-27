# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :v1 do
    resources :cars, only: [:index]
  end
end
