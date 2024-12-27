# frozen_string_literal: true

class Brand < ApplicationRecord
  has_many :cars, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id name]
  end
end
