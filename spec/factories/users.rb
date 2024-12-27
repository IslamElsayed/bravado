# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    preferred_price_range { 30_000..40_000 }
  end
end
