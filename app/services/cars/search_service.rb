# frozen_string_literal: true

module Cars
  class SearchService
    include Pagy::Backend

    def initialize(user, params)
      @user = user
      @params = params
      @preferred_brands = @user.preferred_brands.pluck(:name)
    end

    def call
      cars = fetch_cars
      return [] if cars.empty?

      rank_scores = fetch_rank_scores
      labeled_cars = label_cars(cars, rank_scores)
      sorted_cars = sort_cars(labeled_cars)
      paginate_cars(sorted_cars)
    end

    private

    def fetch_cars
      return [] if @params[:q].blank? || @params[:q].values.all?(&:blank?)

      Car.includes(:brand).ransack(search_params).result
    end

    def fetch_rank_scores
      raw_scores = RankScoreService.fetch_rank_scores(@user.id)
      raw_scores.each_with_object({}) do |score, hash|
        hash[score['car_id'].to_i] = score['rank_score'] if score['rank_score']
      end
    end

    def label_cars(cars, rank_scores)
      cars.map do |car|
        car.rank_score = rank_scores[car.id.to_i] || nil
        car.label = determine_label(car)
        car
      end
    end

    def sort_cars(cars)
      cars.sort_by { |car| [label_priority(car.label), -car.rank_score.to_f, car.price] }
    end

    def paginate_cars(cars)
      _pagy, paginated_cars = pagy_array(cars, page: @params[:page] || 1, items: @params[:per_page] || 20)
      paginated_cars
    end

    def search_params
      {
        brand_name_cont: @params.dig(:q, :brand_name_cont),
        price_gteq: @params.dig(:q, :price_gteq),
        price_lteq: @params.dig(:q, :price_lteq)
      }
    end

    def determine_label(car)
      return unless @preferred_brands.include?(car.brand.name)
      return 'perfect_match' if @user.preferred_price_range.include?(car.price)

      'good_match'
    end

    def label_priority(label)
      case label
      when 'perfect_match'
        0
      when 'good_match'
        1
      else
        2
      end
    end
  end
end
