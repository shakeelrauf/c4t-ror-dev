class Api::V1::DistanceController < ApiController
	before_action :authenticate_user

  def distancediff
  	response =  JSON.parse(get_distanc(params[:origin], params[:destination]))
		return render_json_response(response, :ok)
  end

	# This api will be used by the mobile
  def distance
  	origin = "7628 Flewellyn Rd Stittsville, ON, K2S1B6"
    destination = params[:postal] + " Canada"
    response = get_distance(origin, destination)
		return render_json_response(response, :ok)
  end

  private
  def get_distance(origin, destination)
  	url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&key=#{ENV['GOOGLE_MAP_TOKEN']}&origins=#{origin}&destinations=#{destination}"
		response = get_request(url)
		puts response
		response
  end
end
