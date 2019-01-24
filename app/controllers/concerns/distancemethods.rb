module Distancemethods
  def calculate
    origin = "7628 Flewellyn Rd Stittsville, ON, K2S1B6"
    destination = params[:postal] + " Canada"
    response = get_distance(origin, destination)
    return response
  end

  def get_distance(origin, destination)
    url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&key=#{ENV['GOOGLE_MAP_TOKEN']}&origins=#{origin}&destinations=#{destination}"
    response = get_request(url)
    puts response
    response
  end
end