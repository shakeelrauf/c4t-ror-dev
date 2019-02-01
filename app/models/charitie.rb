class Charitie < ApplicationRecord
	self.table_name = "Charities"
 	validates :email, format: { with: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/ ,message: "Email is invalid." }, if: Proc.new { |charity| charity.email.present?}
	before_save :validate_phone_dashes

	def validate_phone_dashes
		self.phone = Validations.remove_dashes_from_phone(phone)
	end
end
