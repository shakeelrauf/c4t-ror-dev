module Response
  def render_json_response(resource, status)
    render json: resource.to_json, status: status, adapter: :json_api
  end
end