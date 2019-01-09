module SettingHelper

	def label(name)
	  label = ""
	  if name == "steelPrice"
	        label = "Price Of Steel"
		elsif name == "freeDistance"
		  label = "Free Distance In Km"
		elsif name == "excessPrice"
		  label = "Price $ Per Additional Km"
		elsif name == "catalysorPrice"
		  label = "Value Of A Catalytic Converter"
		elsif name == "wheelPrice"
		  label = "Value Of A Wheel"
		elsif name == "batteryPrice"
		  label = "Value Of A Battery"
		end
    label
	end

end
