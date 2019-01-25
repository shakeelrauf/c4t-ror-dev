class HeardofusController < ApplicationController
	# before_action :authenticate_admin
	before_action :login_required
	before_action :check_heardofus, only: [:heardsofus, :update]

	def create
		hou = Heardofus.find_by_type(params[:type])
		if hou.nil?
			hou = Heardofus.new(type: params[:type])
			hou.save!
			flash[:success] = "Created"
			redirect_to "/heardofus"
		else
			flash[:error] = "Name already exist"
			redirect_to "/heardofus/add"
		end
	end

	def get_heardsofus
 		@heardsOfUs = Heardofus.all
	end

	def new
	end

	def edit
	end

	def update
		return  respond_json({:error => HEARDOFUS_NOT_FOUND_MSG, :success => false}) if @heardofus.present?
		@heardofus.update(type: params[:type])
		return respond_json(@heardofus)
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

	def check_heardofus
		@heardofus = Heardofus.find_by_id(params[:no])
	end
end
