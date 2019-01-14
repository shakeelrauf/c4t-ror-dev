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

end
