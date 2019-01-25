class Charitie < ApplicationRecord
	self.table_name = "Charities"
	validates :email, format: { with: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/ }, if: Proc.new { |charity| charity.email.present?}

end
