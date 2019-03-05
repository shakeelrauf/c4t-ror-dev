class AddColumnNewPriceToQuoteCars < ActiveRecord::Migration[5.2]
  def change
    add_column :quote_cars, :new_price, :float
  end
end
