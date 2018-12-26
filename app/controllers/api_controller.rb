class ApiController < ApplicationController
	include Api::V1::MsgConst

  def render_json_response(resource, status)
    render json: resource.to_json, status: status, adapter: :json_api
  end

  #usage
  # return render_json_response({:error => "missing_params", :success => false}, :ok) if params[:content].nil?
	
end
