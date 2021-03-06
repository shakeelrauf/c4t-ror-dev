class Api::V1::LoginController < ApiController
	before_action :authenticate_user, :except => [:token ,:destroy_session]

	def get_token
		return render_json_response({:message => GOOD_TOKEN_MSG, :success => true}, :ok)
	end

	def destroy_session
		user = User.find_by_accessToken(accessToken: request.authorization)
		user.update(accessToken: nil) if user.present?
		return render_json_response({:message => NO_MORE_TOKEN_MSG, :success => true}, :ok)
	end

  def token
  	if(!params["client_id"] ||
         !params["client_secret"] ||
         !params["grant_type"] ||
         params["grant_type"] != "client_credentials")
  		return render_json_response({:error => MISSING_PARAMS_MSG, :success => false}, :bad_request)
		else
			user =  User.where(username: params[:client_id]).first
  		return render_json_response({:error => MISSING_PARAMS_MSG, :success => false}, :bad_request) if (!user || !user.is_valid_password?(params[:client_secret]))
  		token = {}
  		token["token_type"] = "Bearer"
  		token["access_token"] = User.encrypt_token(SecureRandom.random_bytes(128)).gsub('=','').gsub('+','')
  		token["expires_in"] = 3600
  		user.update(accessToken: token["access_token"], dtLastLogin: DateTime.now)
  		return render_json_response(token, :ok)
  	end
  end
end
