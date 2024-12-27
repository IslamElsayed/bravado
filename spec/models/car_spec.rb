# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Brand, type: :model do
  describe 'associations' do
    it { should have_many(:cars).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe '.ransackable_attributes' do
    it 'returns the correct ransackable attributes' do
      expect(Brand.ransackable_attributes).to match_array(%w[created_at id name])
    end
  end
end
