class Satisfaction < ApplicationRecord
	self.table_name = 'satisfactions'

	belongs_to :client ,class_name: 'Customer', foreign_key: 'idClient'

end
