class AddNewColumnsToVehicleInfos < ActiveRecord::Migration[5.2]
  def change
    add_column :vehicle_infos, :ref_id, :string
    add_column :vehicle_infos, :length, :string
    add_column :vehicle_infos, :width, :string
    add_column :vehicle_infos, :height, :string
    add_column :vehicle_infos, :wheelbase, :string
    add_column :vehicle_infos, :engine_type, :string
  end
end
