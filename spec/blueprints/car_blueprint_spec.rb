# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CarBlueprint, type: :blueprint do
  let(:brand) { create(:brand, name: 'Audi') }
  let(:car) { create(:car, brand: brand, price: 35_000, rank_score: 0.9, model: 'A4', label: 'perfect_match') }

  it 'renders the car blueprint correctly' do
    json = CarBlueprint.render(car)
    json_response = JSON.parse(json)
    expect(json_response['id']).to eq(car.id)
    expect(json_response['price']).to eq(car.price)
    expect(json_response['rank_score']).to eq(car.rank_score)
    expect(json_response['model']).to eq(car.model)
    expect(json_response['label']).to eq(car.label)
    expect(json_response['brand']['id']).to eq(brand.id)
    expect(json_response['brand']['name']).to eq(brand.name)
  end
end
