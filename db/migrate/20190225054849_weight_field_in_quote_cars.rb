class WeightFieldInQuoteCars < ActiveRecord::Migration[5.2]
  def change
    add_column :quote_cars , :weight, :float
    add_column :quote_cars , :by_weight, :boolean
  end
end
