module Api::V1::Request
	def get_request(url)
		response = HTTParty.get(url)
		response.body
	end
end