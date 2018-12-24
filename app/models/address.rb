class Address < ApplicationRecord
	self.table_name = 'Address'

	belongs_to :client ,class_name: 'Customer', foreign_key: 'idClient'

	
	def formatLong
		 return this.address + " " + this.city + ", " + this.province
	end
end
