class Api::V1::ContactController < ApiController
	before_action :authenticate_user

	def contact
		business = Business.includes([:contacts]).find(params[:no])
		return render_json_response({:error => CLIENT_NOT_FOUND_MSG, :success => false}, :not_found) if business.nil?
		return render_json_response({:error => CONTACT_CANNOT_DELETED_MSG, :success => false}, :bad_request) if !params[:contacts].present??
		check_format
	  create_contacts                 
	  return render_json_response(business, :ok) 
	end

	private
	def check_format
		params[:contacts].each do |contact|
	  	if (!hasError && 
	  		(!contact["firstName"] || 
	  			!contact["lastName"] ||
	  			!contact["paymentMethod"]))
		  	hasError = true
		  	return render_json_response({:error => CONTACTS_PARAMS_MSG, :success => false}, ::bad_request)
	  	end
	  end     
	end
	
	def create_contacts
		params[:contacts].each do |contact|
	  	c = Contact.new if contact["idContact"].nil? || contact["idContact"] == ''
	  	c = Contact.find(contact["idContact"]) if contact["idContact"].present?
	  	c.idBusiness,c.firstName, c.lastName, c.paymentMethod = params[:no], contact["firstName"], contact["lastName"], contact["paymentMethod"]
	  	c.save!
	  end
	end
end
