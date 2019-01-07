class CharityController < ApplicationController
	# before_action :authenticate_user
	# before_action :authenticate_admin, only: [:heardofus, :update]
	# before_action :check_type, only: [:heardsofus, :update]

	def create
		debugger
		hou = Charitie.new(name: params[:name], phone: params[:phone], email: params[:email], address: params[:address], info: params[:info])
		hou.save!
		redirect_to '/charities'
	end

	def get_charities
		@charities = Charitie.all
	end

	def new
	end

	def edit
		@charitie =  Charitie.find_by_id params[:no]
	end

	def update
		hou = Charitie.where(idCharitie: params[:id])
		hou.first.update(name: params[:name], phone: params[:phone], email: params[:email], address: params[:address], info: params[:info])
		redirect_to '/charities'
	end

	private
	def check_type 
		# return render_json_response({:error => TYPE_ERROR_MSG, :success => false}, :bad_request) if !params[:type].present?
	end

	def charit_params
		
	end
end
