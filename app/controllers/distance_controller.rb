class DistanceController < ApplicationController
  before_action :login_required

	def distance
    postal = params[:postal].gsub(/\s/,'')
    dist = ApiCall.get("/distance/#{postal}", {}, headers)
    puts dist
    respond_json(dist)
  end

end
