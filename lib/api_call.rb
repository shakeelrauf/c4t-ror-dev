require 'httparty'
class ApiCall
	DEFAULT_API_URL = ENV["API_PATH"]

	def self.get url,params={}, headers={"Content-Type" => 'application/json'}
		query_params = "?"
		params.each do |key, val|
 			query_params+="#{key}=#{val}&"
		end
		res = HTTParty.get(DEFAULT_API_URL+url+query_params, headers: headers)
		return res.parsed_response
	end

	def self.post url , params = {},headers={"Content-Type" => 'application/json'}
		res = HTTParty.post(DEFAULT_API_URL+url, body: params,:headers => headers,timeout: 1000000)
		return res.parsed_response
	end
end