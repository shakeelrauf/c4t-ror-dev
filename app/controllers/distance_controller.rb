class DistanceController < ApplicationController
  before_action :login_required
  include Api::V1::Request
  include Distancemethods

	def distance
    postal = params[:postal].gsub(/\s/,'')
    # This api will be used by the mobile
    dist_res = calculate
    dist = JSON.parse(dist_res)
    puts dist_res
    if (dist.present? &&
        dist['rows'].present? &&
        dist['rows'].length > 0 &&
        dist['rows'][0]['elements'].present? &&
        dist['rows'][0]['elements'].length > 0 &&
        dist['rows'][0]['elements'][0].present? &&
        dist['rows'][0]['elements'][0]['distance'].present? &&
        dist['rows'][0]['elements'][0]['distance']['value'].present?)

      # Find the distance value
      d = (dist['rows'][0]['elements'][0]['distance']['value'].to_i / 1000).to_i
      respond_json(d)
    else
      respond_json("-1")
    end
  end
end