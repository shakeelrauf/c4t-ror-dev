class Address < ApplicationRecord
	self.table_name = 'address'

	belongs_to :client   ,class_name: 'Customer', foreign_key: 'idClient', optional: true
	has_one    :quotecar ,class_name: 'Quotecar', foreign_key: 'idAddress'

	def format_long
		address = ""
		address+= "#{self.address} " if self.address.present?
		address+= ", #{self.city} " if self.city.present?
		address+= ", #{self.province}" if self.province.present?
		address+= " #{self.postal}" if self.postal.present?
		address
	end
end
