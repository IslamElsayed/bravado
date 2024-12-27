# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrandBlueprint, type: :blueprint do
  let(:brand) { create(:brand, name: 'Audi') }

  it 'renders the brand blueprint correctly' do
    json = BrandBlueprint.render(brand)
    json_response = JSON.parse(json)
    expect(json_response['id']).to eq(brand.id)
    expect(json_response['name']).to eq(brand.name)
  end
end
