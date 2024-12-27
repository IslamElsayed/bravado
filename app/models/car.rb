# frozen_string_literal: true

class Car < ApplicationRecord
  belongs_to :brand

  attr_accessor :rank_score, :label

  validates :model, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  # Define ransackable attributes
  def self.ransackable_attributes(_auth_object = nil)
    %w[brand_id id model price]
  end

  # Define ransackable associations if needed
  def self.ransackable_associations(_auth_object = nil)
    ['brand']
  end

  # Additional validations and associations can be added here
end
