class ApiController < ApplicationController
	include Api::V1::MsgConst

  def render_json_response(resource, status)
    render json: resource.to_json, status: status, adapter: :json_api
  end

  #usage
  # return render_json_response({:error => "missing_params", :success => false}, :ok) if params[:content].nil?	
	def require_login
    authenticate_token || render_unauthorized("Access denied!")
  end

  def current_user
    @current_user ||= authenticate_token
  end


  protected
  def render_unauthorized(message)
    return render_json_response({:error => INVALID_AUTH, :success => false}, :unauthorized)
  end

  private
  def authenticate_token
    authenticate_with_http_token do |token, options|

      if user = User.where("dtLastLogin >= (NOW() - INTERVAL 1 HOUR) AND isActive = 1 AND accessToken = ?", token)
        ActiveSupport::SecurityUtils.secure_compare(
                        ::Digest::SHA256.hexdigest(token),
                        ::Digest::SHA256.hexdigest(user.accessToken))

        user.update(phone: "") if user.phone.nil?
        user
      end
    end
  end 
end