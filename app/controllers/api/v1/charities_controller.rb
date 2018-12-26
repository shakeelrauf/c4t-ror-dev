class Api::V1::CharitiesController < ApiController
	include API::V1::Validations
	# before_action :authenticate_user

	def index
		charities = Charitie.all
		return render_json_response({:data => charities, :success => true}, :ok)
	end

	def show
		charitie = Charitie.where(idCharitie: params[:no]).first
		if charitie.present?
			return render_json_response({:data => charitie, :success => true}, :ok)
		else
			return render_json_response({:errors => CHARITIE_NOT_FOUND, :success => false}, :not_found)
		end
	end

	def create
		if current_user.roles.eql('admin')
      return render_json_response({:errors => NOT_AN_ADMIN, :success => false}, :bad_request)
    else      
    	if !charitie_params[:name] or !charitie_params[:email] or !charitie_params[:phone] or !charitie_params[:info] or !charitie_params[:address]
    		return render_json_response({:errors => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    	end
    	charitie = Charitie.create(charitie_params)
    	if !charitie.errors[:email].blank?
    		return render_json_response({:errors => INVALID_EMAIL, :success => false}, :bad_request)
    	elsif charitie.errors.any?
    		return render_json_response({:errors => INVALID_CHARITIE, extra_errors: charitie.errors.messages ,:success => false}, :bad_request)
    	else
    		return render_json_response({data: charitie, :success => true}, :ok)
    	end
    end
	end

	def update
		if current_user.roles.eql('admin')
      return render_json_response({:message => NOT_AN_ADMIN, :success => false}, :bad_request)
    else    
    	if !charitie_params[:name] or !charitie_params[:email] or !charitie_params[:phone] or !charitie_params[:info] or !charitie_params[:address]
    		return render_json_response({:errors => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    	end
    	charitie = Charitie.where(idCharitie: params[:no]).first
    	if charitie.present?
    		if charitie.update(charitie_params)
    			return render_json_response({data: charitie, :success => true}, :ok)
    		else
    			return render_json_response({:errors => INVALID_UPDATE_CHARITIE, extra_errors: charitie.errors.messages, :success => false}, :bad_request)	
    		end
    	else
    		return render_json_response({:errors => CHARITIE_NOT_FOUND, :success => false}, :not_found)
   		end
    end
	end

	protected
	def charitie_params
		params.require(:charity).permit(:name, :email, :address, :phone, :info)
	end
end
