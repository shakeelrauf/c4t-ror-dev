class Api::V1::QuoteController < ApiController
	before_action :authenticate_user
end
