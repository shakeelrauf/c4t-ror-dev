module API::V1::Validations
	def format_phone(phone)
		if phone.length < 10
			return false
    end
	end
end