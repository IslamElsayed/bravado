# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::CarsController, type: :controller do
  describe 'GET #index' do
    let(:user) { create(:user) }
    let(:params) { { user_id: user.id, q: { brand_name_cont: 'Audi' }, page: 1, per_page: 10 } }

    before do
      allow(Cars::RankScoreService).to receive(:fetch_rank_scores).and_return([{ 'car_id' => 1, 'rank_score' => 0.9 }])
    end

    it 'returns a successful response' do
      get :index, params: params
      expect(response).to be_successful
    end

    it 'returns the correct JSON structure' do
      brand = create(:brand, name: 'Audi')
      create(:car, brand: brand, price: 35_000)
      get :index, params: params
      json_response = JSON.parse(response.body)
      expect(json_response.first.keys).to contain_exactly('id', 'brand', 'price', 'rank_score', 'model', 'label')
    end

    context 'when the user has preferred brands' do
      let(:preferred_brand) { create(:brand, name: 'Audi') }
      let(:non_preferred_brand) { create(:brand, name: 'Audy') }
      let(:params) { { user_id: user.id, q: { brand_name_cont: 'Aud' }, page: 1, per_page: 10 } }

      before do
        create(:user_preferred_brand, user: user, brand: preferred_brand)
      end

      it 'labels cars correctly based on user preferences' do
        preferred_car = create(:car, brand: preferred_brand, price: 35_000)
        non_preferred_car = create(:car, brand: non_preferred_brand, price: 35_000)
        allow(Cars::RankScoreService).to receive(:fetch_rank_scores).and_return([{ 'car_id' => preferred_car.id, 'rank_score' => 0.9 },
                                                                                 { 'car_id' => non_preferred_car.id,
                                                                                   'rank_score' => 0.8 }])
        get :index, params: params
        json_response = JSON.parse(response.body)
        preferred_car_response = json_response.find { |car| car['id'] == preferred_car.id }
        non_preferred_car_response = json_response.find { |car| car['id'] == non_preferred_car.id }
        expect(preferred_car_response).not_to be_nil
        expect(non_preferred_car_response).not_to be_nil
        expect(preferred_car_response['label']).to eq('perfect_match')
        expect(non_preferred_car_response['label']).to be_nil
      end
    end

    context 'when paginating results' do
      before do
        create_list(:car, 15, brand: create(:brand, name: 'Audi'))
      end

      it 'returns the correct number of cars per page' do
        get :index, params: params
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(10)
      end

      it 'returns the correct cars for the second page' do
        get :index, params: params.merge(page: 2)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(5)
      end
    end

    context 'when the RankScoreService fails' do
      before do
        allow(Cars::RankScoreService).to receive(:fetch_rank_scores).and_return({})
      end

      it 'returns cars without rank scores' do
        brand = create(:brand, name: 'Audi')
        create(:car, brand: brand, price: 35_000)
        get :index, params: params
        json_response = JSON.parse(response.body)
        expect(json_response.first['rank_score']).to be_nil
      end
    end
  end
end
