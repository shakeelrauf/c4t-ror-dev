module Api::V1::Request

  ADDRESS = "7628 Flewellyn Rd Stittsville, ON, K2S 1B6|"
	def get_request(url)
		response = HTTParty.get(url)
		response.body
	end

	def get_distance(r_address)
		two_address = ADDRESS + r_address.format_long
		url = "https://maps.googleapis.com/maps/api/distancematrix/json?key=#{ENV['GOOGLE_MAP_TOKEN']}&origins=#{two_address}&destinations=#{two_address}"
		get_request(url)
		return distance
	end
end