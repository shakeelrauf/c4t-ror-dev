class AddressController < ApplicationController
	before_action :login_required

	def json
		address = Address.find_by_id(params[:id])
		render :json => address.to_json
	end
end
