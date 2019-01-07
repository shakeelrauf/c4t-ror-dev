class HeardofusController < ApplicationController
	# before_action :authenticate_user
	# before_action :authenticate_admin, only: [:heardofus, :update]
	# before_action :check_type, only: [:heardsofus, :update]

	def create
		hou = Heardofus.find_by_type(params[:type])
		if hou.nil?
			hou = Heardofus.new(type: params[:type])
			hou.save!
			redirect_to '/heardofus'
		end
	end

	def get_heardsofus
 		@heardsOfUs = Heardofus.all
	end

	def new
	end

	def edit
		@heardofus =  Heardofus.find_by_id params[:no]
	end

	def update
		hou = Heardofus.find_by_id(params[:no])
		hou.update(type: params[:type])
		redirect_to '/heardofus'
	end

	private
	def check_type 
		# return render_json_response({:error => TYPE_ERROR_MSG, :success => false}, :bad_request) if !params[:type].present?
	end
end
