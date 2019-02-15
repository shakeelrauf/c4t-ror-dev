class Contact < ApplicationRecord
	self.table_name = "contacts"
	belongs_to :business, class_name: 'Business', foreign_key: 'idBusiness'
end
