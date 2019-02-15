class Heardofus < ApplicationRecord
	self.table_name = 'heardsofus'
	self.inheritance_column = nil
	has_many :customers, foreign_key: :idHeardOfUs
end
