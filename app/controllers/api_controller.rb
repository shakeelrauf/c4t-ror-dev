class ApiController < ApplicationController
	include Api::V1::MsgsConst
  
  helper_method :current_user
  helper_method :authenticate_user

  def render_json_response(resource, status)
    render json: resource.to_json, status: status, adapter: :json_api
  end

  #usage
  # return render_json_response({:error => "missing_params", :success => false}, :ok) if params[:content].nil?	

  def authenticate_user
    return render_json_response({:error => HEADERS_MSG, :success => false}, :ok) if !request.authorization.present?
    return render_json_response({:error => INVALID_AUTH, :success => false}, :ok) if current_user.nil?
    return current_user
  end

  def test
  end


  def authenticate_admin
    return render_json_response({:error => NOT_ADMIN_MSG, :success => false}, :unauthorized) if current_user.roles != "admin"
  end

  def current_user
    user = User.where("dtLastLogin >= (NOW() - INTERVAL 1 HOUR) AND isActive = 1 AND accessToken = ?", request.authorization).first
    if user.present?
      user.phone = "" if user.phone.nil?
      return user
    else
      return nil
    end
  end

end