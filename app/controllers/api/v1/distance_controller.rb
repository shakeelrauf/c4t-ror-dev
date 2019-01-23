class Api::V1::DistanceController < ApiController
	before_action :authenticate_user

  def distancediff
  	response =  JSON.parse(get_distanc(params[:origin], params[:destination]))
		return render_json_response(response, :ok)
  end

  def distance
  	origin = "7628 Flewellyn Rd Stittsville, ON, K2S1B6"
    destination = params[:postal] + " Canada"
    response = getDistance(origin, destination)
		return render_json_response(response, :ok)
  end

  private
  def get_distanc(origin, destination)
  	url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&key=#{ENV["GOOGLE_MAP_TOKEN"]}&origins=#{origin}&destinations=#{destination}"
		response = get_request(url)
    response
  end
end
