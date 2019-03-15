class VehicleInfoSearchable < ActiveRecord::Migration[5.2]
  def change
    add_column :vehicle_infos, :searchable, :string
    VehicleInfo.all.each do |v|
      v.save!
    end
  end
end
