module CustomersHelper

	def background_color(status_color)
		backgroundType = "muted"
		if status_color == "yellow"
			backgroundType = "warning"
		elsif status_color == "blue"
			backgroundType = "info"
		elsif status_color == "green"
			backgroundType = "success"
		elsif status_color == "red"
			backgroundType = "danger"
		elsif status_color == "orange"
			backgroundType = "primary"
		end
		backgroundType
	end

	def province_name(name)
		val = ""
		if name == "ON"
			val = "Ontario"
		elsif name == "BC"
			val = "British Columbia"
		elsif name == "QC"
			val = "Quebec"
		elsif name == "AL"
			val = "Alberta"
		elsif name == "NS"
			val = "Nova Scotia"
		elsif name == "NL"
			val = "Newfoundland and Labrador"
		elsif name == "SA"
			val = "Saskatchewan"
		elsif name == "MA"
			val = "Manitoba"
		elsif name == "NB"
			val = "New Brunswick"
		elsif name == "PE"
			val = "Prince Edward Island"
		else
			val = name
		end
		val
	end

	def has_business_contacts?(action, customer)
		customer.try(:business).try(:contacts)
	end

  def business_contact_position(customer)
    customer.try(:business).try(:contactPosition)
  end

  def business_name(customer)
    customer.try(:business).try(:name)
  end

  def business_desc(customer)
    customer.try(:business).try(:description)
  end

  def business_pstax(customer)
    customer.try(:business).try(:pstTaxNo)
  end

  def business_gstax(customer)
    customer.try(:business).try(:gstTaxNo)
  end
  
  def business_usersFlatFee(customer)
    customer.try(:business).try(:usersFlatFee)
  end

  def customer_address(customer)
    customer.try(:address)
  end

  def quote_created_at(date)
    DateTime.parse(date).strftime('%d/%m/%Y, %I:%M:%S:%p')
  end

  def phone_type(customer)
    if customer.phone_type == "primary"
    	customer.phone
    elsif customer.phone_type == "cell"
    	customer.cellPhone
    elsif customer.phone_type == "other"
    	customer.secondaryPhone
    else
    	customer.phone
    end
  end

end
