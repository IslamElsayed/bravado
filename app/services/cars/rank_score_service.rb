# frozen_string_literal: true

require 'net/http'
require 'json'
module Cars
  class RankScoreService
    BASE_URL = ENV['RANK_SCORE_API_URL']

    def self.fetch_rank_scores(user_id)
      Rails.cache.fetch("rank_scores/#{user_id}", expires_in: 1.day) do
        response = get_rank_scores(user_id)
        parse_response(response)
      end
    end

    def self.get_rank_scores(user_id)
      uri = URI("#{BASE_URL}?user_id=#{user_id}")
      Net::HTTP.get_response(uri)
    end

    def self.parse_response(response)
      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      else
        handle_error(response)
      end
    rescue JSON::ParserError
      handle_error(response)
    end

    def self.handle_error(response)
      # Log the error or notify the appropriate service
      Rails.logger.error("Failed to fetch rank scores: #{response.code} #{response.message}")
      {}
    end
  end
end
