class Api::V1::VehiclesController < ApiController
	before_action :authenticate_user
	include API::V1::Validations

	def create
    if invalid_params
      return render_json_response({:error => INVALID_PARAMS, :success => false}, :unprocessable_entity)
    else
      r_vehicle = VehicleInfo.create(vehicle_params)
      return render_json_response(r_vehicle, :ok) if r_vehicle
      return render_json_response({:error => PROBLEM_OCCURRED, :success => false}, :unprocessable_entity)
    end
	end

	def show
		info = VehicleInfo.where(idVehiculeInfo: params[:no]).first
    if info.nil?
      return render_json_response({:error => VEHICLE_NOT_FOUND, :success => false}, :not_found)
    else
    	return render_json_response(info, :ok) 
    end
	end

	def index
		limit = 30
    offset = 0
    limit = (params[:limit].present? ? params[:limit].to_i : 30)
    offset = ((params[:offset].to_i) * limit) if params[:offset] != "-1"
    if params[:filter].present?
      filter = + params[:filter].gsub(/[\s]/, "% %") + "%"
      filters = filter.split(' ')
      query = "Select * from VehiculesInfo where"
      filters.each do |fil|
      	query.concat(" year LIKE '#{fil}' OR make LIKE '#{fil}' OR model LIKE '#{fil}' OR trim LIKE '#{fil}' OR body LIKE '#{fil}' OR drive LIKE '#{fil}' OR transmission LIKE '#{fil}' OR seats LIKE '#{fil}' OR doors LIKE '#{fil}' OR weight LIKE '#{fil}'")
      	query.concat(" AND ") if !fil.eql?(filters.last)
			end
	    r_vehicles = VehicleInfo.run_sql_query(query, offset, limit)
			return render_json_response(r_vehicles, :ok) if r_vehicles
			return render_json_response({:error => VEHICLE_NOT_FOUND, :success => false}, :not_found)
		end
		r_vehicles = VehicleInfo.all.limit(limit).offset(offset) if !params[:filter].present?
		return render_json_response(r_vehicles, :ok)
	end

	def vehicle_count
		limit = params[:limit].gsub("?","").to_i
    if params[:filter].present?
			filter = "%" + params[:filter].gsub(/[\s]/, "% %") + "%"
			filters = filter.split(' ')
			query = "Select * from VehiculesInfo where"
			filters.each do |fil|
				query.concat(" year LIKE '#{fil}' OR make LIKE '#{fil}' OR model LIKE '#{fil}' OR trim LIKE '#{fil}' OR body LIKE '#{fil}' OR drive LIKE '#{fil}' OR transmission LIKE '#{fil}' OR seats LIKE '#{fil}' OR doors LIKE '#{fil}' OR weight LIKE '#{fil}'")
				query.concat(" AND ") if !fil.eql?(filters.last)
			end
			count = VehicleInfo.run_sql_query(query).count
	    return render_json_response((count/limit).ceil, :ok) if count
	    return render_json_response({:error => VEHICLE_NOT_FOUND, :success => false}, :not_found)
		else
			count = VehicleInfo.all.count
			return render_json_response((count/limit).ceil, :ok) if count
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
		params.permit(:idVehiculeInfo, :year, :make, :model, :trim, :body, :drive, :transmission, :seats, :doors, :weight)
	end
end