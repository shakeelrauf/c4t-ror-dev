class Schedule < ApplicationRecord
	self.table_name = 'Schedules'
	
	belongs_to :car ,class_name: 'QuoteCar', foreign_key: 'idCar'

end
