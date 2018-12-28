class Api::V1::VehiclesController < ApiController
	before_action :authenticate_user
	include API::V1::Validations
	def create
		if current_user.roles.eql?('admin')
  		return render_json_response({:error => NOT_AN_ADMIN, :success => false}, :not_found)
  	else
      if invalid_params
        return render_json_response({:error => INVALID_PARAMS, :success => false}, :unprocessable_entity)
      else
        r_vehicle = VehicleInfo.create(vehicle_params)
        return render_json_response(r_vehicle, :ok) if r_vehicle
        return render_json_response({:error => PROBLEM_OCCURRED, :success => false}, :unprocessable_entity)
      end
    end
	end

	def show
		info = VehicleInfo.where(id: params[:no])
    if !info
      return render_json_response({:error => VEHICLE_NOT_FOUND, :success => false}, :not_found)
    else
    	return render_json_response(info, :ok) 
    end
	end

	def index
		limit = 30;
    offset = 0;
    where = {};
    
    limit = to_number(params[:limit]) if limit_valid
    offset = (to_number(params[:offset]) * limit) if offset_valid
    
    if params[:filter]
      filter = "%" + params[:filter].gsub(/[\s]/, "% %") + "%"
      filters = filter.split(' ')
      query = ""
      filters.each do |filter|
      	query.concat("(year LIKE #{fil} or make LIKE #{fil} or model LIKE #{fil} or trim LIKE #{fil} or body LIKE #{fil} or drive LIKE #{fil} or transmission LIKE #{fil} or seats LIKE #{fil} doors LIKE #{fil} or weight LIKE #{fil})")
      	query.concat(" and ") if !fil.eql?(filters.last)
      end
			
	    r_vehicles = VehicleInfo.where(query).offset(offset).limit(limit)   
	    return render_json_response(r_vehicles, :ok) if r_vehicles
	    return render_json_response({:error => VEHICLE_NOT_FOUND, :success => false}, :not_found)
	  end
	end

	def vehicle_count
    limit = 30;
    offset = 0;
    where = {};
    
    limit = to_number(params[:limit]) if limit_valid
    offset = (to_number(params[:offset]) * limit) if offset_valid
    
    if params[:filter]
      filter = '%' + params[:filter].gsub(/[\s]/, '% %') + '%'
      filters = filter.split(' ')
      query = ""
      filters.each do |fil|
      	query.concat("(year LIKE #{fil} or make LIKE #{fil} or model LIKE #{fil} or trim LIKE #{fil} or body LIKE #{fil} or drive LIKE #{fil} or transmission LIKE #{fil} or seats LIKE #{fil} doors LIKE #{fil} or weight LIKE #{fil})")
      	query.concat(" and ") if !fil.eql?(filters.last)
      end
			
	    count = VehicleInfo.where(query).count
	    return render_json_response((count/limit).ceil, :ok) 
	    return render_json_response({:error => VEHICLE_NOT_FOUND, :success => false}, :not_found)
	  end
	end

	private 
	def invalid_params
		!is_number(params[:year]) || !params[:make] || !params[:model] || !is_number(params[:weight])
	end

	def limit_valid
		params[:limit] && is_number(params[:limit]) && to_number(params[:limit]) > 0
	end

	def offset_valid
		params[:offset] && is_number(params[:offset]) && to_number(params[:limioffsett]) > 0
	end
	def vehicle_params
		params.permit(:vehicle, :year, :make, :model, :trim, :body, :drive, :transmission, :seats, :doors, :weight)
	end
end