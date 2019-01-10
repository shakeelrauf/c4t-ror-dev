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

end
