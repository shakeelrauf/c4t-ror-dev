class Api::V1::HeardofusController < ApiController
	before_action :authenticate_user
	before_action :authenticate_admin, only: [:heardofus, :update]
	before_action :check_type, only: [:heardsofus, :update]

	def heardsofus
		hou = Heardofu.find_by_type(params[:type]) 
		if hou.nil?
			hou = Heardofu.new(type: params[:type])
			hou.save!
			return render_json_response(hou, :ok)
		else
			return render_json_response({:error => TYPE_ALREADY_ERROR_MSG, :success => false}, :bad_request)
		end
	end

	def get_heardsofus
 		hous = Heardofu.all
 		return render_json_response(hous, :ok)
	end

	def show
		hou =  Heardofu.find_by_id params[:no]
		return render_json_response({:error => HEARDOFUS_NOT_FOUND_MSG, :success => false}, :not_found) if !hou.present?
		return render_json_response(hou, :ok)
	end

	def update
		hou = Heardofu.find_by_id(params[:no])
		return render_json_response({:error => HEARDOFUS_NOT_FOUND_MSG, :success => false}, :not_found) if !hou.present?
		hou.update(type: params[:type])
		return render_json_response(hou, :ok)
	end

	private
	def check_type 
		return render_json_response({:error => TYPE_ERROR_MSG, :success => false}, :bad_request) if !params[:type].present?
	end

end
