class AddStillDrivingToQuotesCars < ActiveRecord::Migration[5.2]
  def change
    add_column :QuotesCars, :still_driving, :boolean
  end
end
