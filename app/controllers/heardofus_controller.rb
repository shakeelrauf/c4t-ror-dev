class HeardofusController < ApplicationController
	# before_action :authenticate_user
	# before_action :authenticate_admin
	# before_action :check_type, only: [:heardsofus, :update]

	def create
    res = ApiCall.post("/heardsofus", form_body(params), headers )
		redirect_to '/heardofus'
	end

	def get_heardsofus
 		# @heardsOfUs = Heardofus.all
    @heardsOfUs = ApiCall.get("/heardsofus",{}, headers)
	end

	def new
	end

	def edit
		@heardofus = ApiCall.get("/heardsofus/#{params[:no]}", {}, headers)
	end

	def update
    res = ApiCall.put("/heardsofus/#{params[:no]}", form_body(params), headers)
		redirect_to '/heardofus'
	end

	def form_body(params)
    {
      "type":      params[:type]
    }
  end

	private
	def check_type 
		# return render_json_response({:error => TYPE_ERROR_MSG, :success => false}, :bad_request) if !params[:type].present?
	end
end
