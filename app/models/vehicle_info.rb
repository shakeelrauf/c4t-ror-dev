class VehicleInfo < ApplicationRecord
	self.table_name = 'vehicle_infos'

	before_save :on_before_save

  # make the searchable index
	def on_before_save
		s = "#{self.ref_id} #{self.make} #{self.model} #{self.trim} #{self.body} #{self.drive} #{self.transmission}"
		puts s
		self.searchable = s
	end
end
