# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cars::RankScoreService, type: :service do
  describe '.fetch_rank_scores' do
    let(:user_id) { 1 }
    let(:url) { "RANK_SCORE_API_URL?user_id=#{user_id}" }

    context 'when the request is successful' do
      it 'returns rank scores for the given user' do
        response_body = [{ 'car_id' => 1, 'rank_score' => 0.9 }].to_json
        stub_request(:get, url).to_return(status: 200, body: response_body, headers: {})

        rank_scores = RankScoreService.fetch_rank_scores(user_id)
        expect(rank_scores).to eq({ 1 => 0.9 })
      end
    end

    context 'when the request fails with a 500 status' do
      it 'handles the failure gracefully and returns an empty hash' do
        stub_request(:get, url).to_return(status: 500, body: '', headers: {})

        rank_scores = RankScoreService.fetch_rank_scores(user_id)
        expect(rank_scores).to eq({})
      end
    end

    context 'when the request fails with a 404 status' do
      it 'handles the failure gracefully and returns an empty hash' do
        stub_request(:get, url).to_return(status: 404, body: '', headers: {})

        rank_scores = RankScoreService.fetch_rank_scores(user_id)
        expect(rank_scores).to eq({})
      end
    end

    context 'when the response is not valid JSON' do
      it 'handles the failure gracefully and returns an empty hash' do
        stub_request(:get, url).to_return(status: 200, body: 'invalid json', headers: {})

        rank_scores = RankScoreService.fetch_rank_scores(user_id)
        expect(rank_scores).to eq({})
      end
    end

    context 'when the request times out' do
      it 'handles the failure gracefully and returns an empty hash' do
        stub_request(:get, url).to_timeout

        rank_scores = RankScoreService.fetch_rank_scores(user_id)
        expect(rank_scores).to eq({})
      end
    end
  end
end
