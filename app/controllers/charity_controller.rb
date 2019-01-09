class CharityController < ApplicationController
	# before_action :authenticate_user
	# before_action :authenticate_admin

	def create
    res = ApiCall.post("/charities", form_body(params), headers )
		redirect_to '/charities'
	end

	def get_charities
 		# @heardsOfUs = Heardofus.all
    @charities = ApiCall.get("/charities",{}, headers)
	end

	def new
	end

	def edit
		@charitie = ApiCall.get("/charities/#{params[:no]}", {}, headers)
	end

	def update
    res = ApiCall.put("/charities/#{params[:id]}", form_body(params), headers)
		redirect_to '/charities'
	end

	def form_body(params)
    {
      "name":      params[:name],
      "phone": 		 params[:phone],
      "email": 		 params[:email],
      "address": 	 params[:address],
      "info": 		 params[:info]
    }
  end

end
