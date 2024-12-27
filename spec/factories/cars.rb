# frozen_string_literal: true

FactoryBot.define do
  factory :car do
    price { 35_000 }
    model { 'A4' }
    association :brand
  end
end
