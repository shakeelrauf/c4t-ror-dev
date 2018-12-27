class IsValid
	def self.address item, callback=nil
		url = "https://maps.googleapis.com/maps/api/geocode/json?key=#{ENV['GOOGLE_MAP_TOKEN']}&address=#{item}"
		r_address = HTTParty.get(url)    
    return false if r_address.results.length == 0
    return r_address.results[0]
	end

	def self.format_address_components address_components, callback=nil
    return_data = {}
    address_components.each do |component|
    	return_data[component["types"][0]] = component["long_name"]
    end
    return return_data;
  end

  def self.currency expression, allow_negative_value, callback=nil
		return false if !expression
		expression = expression.gsub(/,/, ".")
		length = (expression.match(/\./) || []).length
		length.times do
      expression = expression.gsub(".", "");
		end
		if (allow_negative_value && /^-?\d+(\.\d{1,2})?$/.match(expression))
			if(!/^\.\d$/.match(expression.expression.last(2)) && !/^\.\d{2}$/.match(expression.last(3)))
				expression += ".00"
			elsif (/^\.\d$/.match(expression.last(2)))
				expression += "0"
			end
			return expression
		elsif (!allow_negative_value && /^\d+(\.\d{1,2})?$/.match(expression))
			if(!/^\.\d$/.match(expression.last(2)) && !/^\.\d{2}$/.match(expression.last(3))) 
				expression += ".00"
			elsif (/^\.\d$/.match(expression.last(2)))
				expression += "0"
			end
			return expression
		else
			return false
		end
  end

  def self.date item
  	return true if item && item.to_s.length == 10 &&  DateTime.strptime(item, '%Y-%m-%d')
  	return false
  end

  def self.datetime item
  	return true if item && item.to_s.length == 19 &&  DateTime.strptime(item, '%Y-%m-%d %H:%M:%S')
  	return false
  end

  def self.email item
  	return true if /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.match(item)
  	return false
  end

  def self.lang item
  	return true if(item === "en" || item === "fr")
    return false
  end


  def self.name item
  	return true if /^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ\s_-]+$/.match(item)
    return false;
  end

  def self.password item
  	return false if(!item || item.length < 8)
  	return true if(/[A-Z]/.match(item) && /[a-z]/.match(item) && /\d/.match(item))
  	return false
  end

  def self.phone_digit_only expression
  	return false if(!expression)
  	phone = ""
  	expression.length.times do |i|
  		if (expression[i] != nil) && (expression[i] != "")
  			phone += expression[i]
  		end
  	end
  	return false if phone.length < 10
  	return phone
  end

  def self.province_abbr item
  	mapping = ["CDN", "AB", "BC", "MB", "NB", "NF", "NS", "ON", "PE", "QC", "SK", "NT", "NU", "YT", "USA", "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "AS", "GU", "MP", "PR", "VI", "MEX", "AG", "BN", "BS", "CH", "CI", "CL", "CP", "CS", "DF", "DG", "GE", "GJ", "HD", "JA", "MC", "MR", "MX", "NA", "NL", "OA", "PU", "QE", "QI", "SI", "SL", "SO", "TA", "TB", "TL", "VC", "YU", "ZA", "OT"]
  	return true if mapping.find{|key| key == item}
  	return false
  end

  def self.role expression
  	return true if (expression === "admin" || expression === "user")
    return false
  end

  def self.time item
    return true if(item && item.to_s.length == 8 && DateTime.strptime(item, '%H:%M:%S'))
    return false
  end

  def self.username item, callback=nil
    return true if (/^[a-zA-Z0-9_.-]{6,}$/.match(item))
    return false
  end
end