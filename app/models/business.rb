class Business < ApplicationRecord
	self.table_name = "Business"
	belongs_to :client, class_name: 'Customer', foreign_key: 'idClient' 
	has_many :contacts, class_name: 'Contact', foreign_key: 'idBusiness'
end
