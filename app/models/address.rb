class Address < ApplicationRecord
	self.table_name = 'address'

	belongs_to :client   ,class_name: 'Customer', foreign_key: 'idClient', optional: true
	has_one    :quotecar ,class_name: 'Quotecar', foreign_key: 'idAddress'

	def format_long
		return (self.address + " " + self.city + ", " + self.province)
	end
end
