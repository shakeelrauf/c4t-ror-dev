class VehicleInfo < ApplicationRecord
	self.table_name = 'vehicle_infos'

	before_save :on_before_save

	def on_before_save
	end
end
