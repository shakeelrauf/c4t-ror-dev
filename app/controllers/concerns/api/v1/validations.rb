module API::V1::Validations
	def format_phone(phone)
		if phone.length < 10
			return false
    end
	end

	def is_number(number)
    true if Float(number) rescue false
  end

  def to_number(number)
  	number.to_i if is_number(number)
  end
end