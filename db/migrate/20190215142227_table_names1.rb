class TableNames1 < ActiveRecord::Migration[5.2]
  def change
    rename_table :vehiculesinfo, :vehicule_infos
    rename_table :QuotesCars, :quote_cars
  end
end
