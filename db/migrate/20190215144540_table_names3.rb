class TableNames3 < ActiveRecord::Migration[5.2]
  def change
    rename_table :vehicule_infos, :vehicle_infos
  end
end
