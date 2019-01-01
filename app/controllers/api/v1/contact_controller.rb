class Api::V1::ContactController < ApiController
	before_action :authenticate_user

	def contact
		business = Business.includes(:contacts).find_by_idClient(params[:no]).to_json(:contacts)
		return render_json_response({:error => CLIENT_NOT_FOUND_MSG, :success => false}, :not_found) if business.nil?
		return render_json_response({:error => CONTACTS_PARAMS_MSG, :success => false}, :bad_request) if !params[:contacts].present?
		return render_json_response({:error => CONTACTS_PARAMS_MSG, :success => false}, :bad_request) if check_format
	  create_contacts
		return render json: business, status: :ok, adapter: :json_api
	end

	private
	def check_format
		params[:contacts].each do |contact|
	  	if (!contact["firstName"] ||
	  			!contact["lastName"] ||
	  			!contact["paymentMethod"])
				return false
	  	end
		end
		return true
	end
	
	def create_contacts
		params[:contacts].each do |contact|
	  	c = Contact.new if contact["idContact"].nil? || contact["idContact"] == ''
	  	c = Contact.find_by_id(contact["idContact"]) if contact["idContact"].present?
	  	c.idBusiness,c.firstName, c.lastName, c.paymentMethod = params[:no], contact["firstName"], contact["lastName"], contact["paymentMethod"]
	  	c.save!
	  end
	end
end
