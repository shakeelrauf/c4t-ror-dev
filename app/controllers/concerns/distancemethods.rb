module Distancemethods
  include Api::V1::Request
  def calculate
    origin = "7628 Flewellyn Rd Stittsville, ON, K2S1B6"
    destination = params[:postal] + " Canada"
    response = get_distance(origin, destination)
    return response
  end

  def calculate_by_postal_code(postal)
    origin = "7628 Flewellyn Rd Stittsville, ON, K2S1B6"
    destination = postal + " Canada"
    response = JSON.parse get_distance(origin, destination)
    if response["rows"].present? && response["rows"][0]["elements"].present?  && response["rows"][0]["elements"][0]["distance"].present?
      return response["rows"][0]["elements"][0]["distance"]["value"]/1000
    else
      return 0
    end
  end

  def get_distance(origin, destination)
    url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&key=#{ENV['GOOGLE_MAP_TOKEN']}&origins=#{origin}&destinations=#{destination}"
    response = get_request(url)
    puts response
    response
  end
end