# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cars::SearchService, type: :service do
  let(:user) { create(:user) }
  let(:params) { { q: { brand_name_cont: 'Aud' }, page: 1, per_page: 10 } }
  let(:service) { described_class.new(user, params) }
  let(:brand) { create(:brand, name: 'Audi') }
  let!(:car) { create(:car, brand: brand, price: 35_000) }
  before do
    allow(user).to receive(:preferred_brands).and_return([brand])
    allow(user).to receive(:preferred_price_range).and_return(30_000..40_000)
  end

  describe '#call' do
    context 'with search price within range' do
      it 'returns paginated cars' do
        create_list(:car, 15, brand: brand, price: 45_000)
        paginated_cars = service.call
        expect(paginated_cars.size).to eq(10)
      end

      it 'labels car correctly' do
        paginated_cars = service.call
        expect(paginated_cars.first.label).to eq('perfect_match')
      end

      it 'labels car as good_match' do
        car.update(price: 50_000)
        paginated_cars = service.call
        expect(paginated_cars.first.label).to eq('good_match')
      end

      it 'labels car as nil' do
        brand.update(name: 'Audy')
        allow(user).to receive(:preferred_brands).and_return([create(:brand, name: 'Audi')])
        paginated_cars = service.call
        expect(paginated_cars.first.label).to be_nil
      end
    end

    context 'with search price out of range' do
      let!(:params) { { q: { brand_name_cont: 'Aud', price_gteq: 30_000, price_lteq: 40_000 }, page: 1, per_page: 10 } }

      it 'returns cars within search price range' do
        create_list(:car, 15, brand: brand, price: 20_000)
        create_list(:car, 15, brand: brand, price: 45_000)
        paginated_cars = service.call
        expect(paginated_cars.size).to eq(1)
      end
    end
  end
end
