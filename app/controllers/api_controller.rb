class ApiController < ApplicationController
	include Api::V1::MsgsConst
  include Response
  include Api::V1::Request
  include API::V1::Validations
  before_action :validate_token
  helper_method :current_user
  # helper_method :authenticate_user

  def validate_token
    if request.authorization.present?
      return true if User.find_by_accessToken(request.authorization).present?
      return false
    end
    return true
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
    return render_json_response({:error => NOT_ADMIN_MSG, :success => false}, :unauthorized) if current_user && current_user.roles != "admin"
  end

  def params_present? given_params, check_params
    check_params.each do |p|
     return false if !given_params["#{p}"].present?
    end
    return true
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