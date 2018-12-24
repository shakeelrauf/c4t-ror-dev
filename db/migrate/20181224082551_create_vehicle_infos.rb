class CreateVehicleInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicle_infos do |t|

      t.timestamps
    end
  end
end
