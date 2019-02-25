class QuoteCar < ApplicationRecord
	self.table_name = 'quote_cars'
	belongs_to :quote ,class_name: 'Quote', foreign_key: 'idQuote'
	belongs_to :information ,class_name: 'VehicleInfo', foreign_key: 'idCar'
	belongs_to :address ,class_name: 'Address', foreign_key: 'idAddress', optional: true
	has_one :schedule, class_name: "Schedule", foreign_key: 'idCar', dependent: :destroy

	def booking_reference_no
		format '%06d',self.id
	end
end
