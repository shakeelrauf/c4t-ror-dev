class Satisfaction < ApplicationRecord
	self.table_name = 'Satisfactions'

	belongs_to :client ,class_name: 'Customer', foreign_key: 'idClient'

end
