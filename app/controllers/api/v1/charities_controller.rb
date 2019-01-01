class Api::V1::CharitiesController < ApiController

	# before_action :authenticate_user
	# before_action :authenticate_admin, only: [:create, :update]

	def index
		charities = Charitie.all
		return render_json_response(charities, :ok)
	end

	def show
		charitie = Charitie.where(idCharitie: params[:no]).first
		if charitie.present?
			return render_json_response(charitie, :ok)
		else
			return render_json_response({:errors => CHARITIE_NOT_FOUND}, :not_found)
		end
	end

	def create
		return render_json_response({:errors => REQUIRED_ATTRIBUTES}, :bad_request) if !params_present?(charitie_params, ["name", "email", "phone", "info", "address"])
  	charitie = Charitie.new(charitie_params)
  	charitie.save
  	if !charitie.errors[:email].blank?
  		return render_json_response({:errors => INVALID_EMAIL}, :bad_request)
  	elsif charitie.errors.any?
  		return render_json_response({:errors => INVALID_CHARITIE, extra_errors: charitie.errors.messages}, :bad_request)
  	else
  		return render_json_response(charitie, :ok)
  	end
	end

	def update    
		return render_json_response({:errors => REQUIRED_ATTRIBUTES}, :bad_request) if !params_present?(charitie_params, ["name", "email", "phone", "info", "address"])
  	charitie = Charitie.where(idCharitie: params[:no]).first
  	if charitie.present?
  		if charitie.update(charitie_params)
  			return render_json_response(charitie, :ok)
  		else
  			return render_json_response({:errors => INVALID_UPDATE_CHARITIE, extra_errors: charitie.errors.messages}, :bad_request)	
  		end
  	else
  		return render_json_response({:errors => CHARITIE_NOT_FOUND}, :not_found)
 		end
	end

	protected
	def charitie_params
		params.permit(:name, :email, :address, :phone, :info)
	end
end
