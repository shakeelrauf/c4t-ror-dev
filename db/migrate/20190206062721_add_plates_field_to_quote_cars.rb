class AddPlatesFieldToQuoteCars < ActiveRecord::Migration[5.2]
  def change
    add_column :QuotesCars, :platesOn, :integer
  end
end
