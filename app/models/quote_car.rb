class QuoteCar < ApplicationRecord
	self.table_name = 'QuotesCars'

	belongs_to :quote ,class_name: 'Quote', foreign_key: 'idQuote'
	belongs_to :information ,class_name: 'VehicleInfo', foreign_key: 'idCar'
	belongs_to :address ,class_name: 'Address', foreign_key: 'idAddress'
	has_one :schedule, class_name: "Schedule", foreign_key: 'idCar'

end
