# frozen_string_literal: true

class CarBlueprint < Blueprinter::Base
  identifier :id

  fields :price, :rank_score, :model, :label

  association :brand, blueprint: BrandBlueprint
end
