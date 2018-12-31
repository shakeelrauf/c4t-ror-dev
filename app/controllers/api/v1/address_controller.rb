require 'action_view'

class Api::V1::AddressController < ApplicationController
	before_action :authenticate_user
	include ActionView::Helpers::NumberHelper

	def client_address
		return render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :not_found) if check_params
		r_address = IsValid.address(params[:address] + " " + params[:city] + ", " + params[:province])
		return render_json_response({:error => ADDRESS_NOT_EXIST_MSG, :success => false}, :not_found) if r_address == false
		address_components = IsValid.format_address_components(r_address["address_components"])
    two_address = "7628 Flewellyn Rd Stittsville, ON, K2S 1B6|" + r_address
    url = "https://maps.googleapis.com/maps/api/distancematrix/json?key=#{ENV['GOOGLE_MAP_TOKEN']}&origins=#{two_address}&destinations=#{two_address}"
    distance = get_request(url)
    going, returning  =  0,0
    going , returning = distance["rows"][0]["elements"][1]["distance"]["value"],distance["rows"][1]["elements"][0]["distance"]["value"] if check_address(distance)
    client = Customer.includes([:address]).find_by_id(params[:no])
    return render_json_response({:error => CLIENT_NOT_FOUND_MSG, :success => false}, :not_found) if client.nil? 
    params[:addresses].each do |addresses|
			Address.create(idClient: client.id,
	                  	address: address_components["street_number"] + " " + address_components["route"],
	                    city: address_components["locality"],
	                    postal: address_components["postal_code"],
	                    province: address_components["administrative_area_level_1"],
	                    distance: going.to_i + returning.to_i )

    end
		return render_json_response(client, :ok)  
	end

	def address
		limit, offset = 10, 0
		where = "idClient = #{params[:no]}"
    limit = params[:limit].to_i if (params[:limit] != nil && params[:limit].integer?)
    offset = params[:offset].to_i if (params[:offset] != nil && params[:offset].integer?)
    query = query_builder(param[:filters]) if param[:filters]

  	list = Address.run_sql_query(query,offset, limit)
		return render_json_response(list, :ok)   
	end

	def show
		address = Address.find_by_id(params[:no])
		return render_json_response(address, :ok)
	end

	def destroy
		count = QuoteCar.where(idAddress: params[:addressId]).count
		return render_json_response({error: NO_CAR_MSG, success: false}, :not_found) if count <= 0
		Address.where(idAddress: params[:addressId]).destroy_all
		return render_json_response({message: ADDRESS_DELETE_MSG, success: true}, :ok)
	end

	def create
		address = Address.create(idClient: params[:clientId], address: "",city: "",province: "",postal: "",distance: "")
		return render_json_response(address, :ok)   
	end

	def distance
		r_address =  Address.find_by_idAddress(params[:no])
		return render_json_response({error: ADDRESS_NOT_FOUND, success: false}, :not_found)  if r_address.nil?
    two_address = "7628 Flewellyn Rd Stittsville, ON, K2S 1B6|" + r_address.format_long
    url = "https://maps.googleapis.com/maps/api/distancematrix/json?key=#{ENV['GOOGLE_MAP_TOKEN']}&origins=#{two_address}&destinations=#{two_address}"
    distance = get_request(url)
    r_setting  = setting.where('dtCreated IN (SELECT MAX(dtCreated) FROM Settings GROUP BY name)')
    freeDistance =  r_setting.find{|set| set.name=="freeDistance"}
    excessPrice =  r_setting.find{|set| set.name=="excessPrice"}
    return render_json_response({error: ADDRESS_INVALID_MSG, success: false}, :bad_request)  if check_address(distance)
    excessDistance = distance["rows"][0]["elements"][1]["distance"]["value"] / 1000 + distance["rows"][1]["elements"][0]["distance"]["value"] / 1000 - freeDistance
    additionnalPrice = number_with_precision((excessPrice * excessDistance), precision: 2)
    render_json_response({
        "origin": "7628 Flewellyn Rd Stittsville, ON, K2S1B6",
        "destination": r_address.format_long,
        "goingDistance": distance["rows"][0]["elements"][1]["distance"]["value"] / 1000,
        "goingDuration":  distance["rows"][0]["elements"][1]["duration"]["value"],
        "comingBackDistance": distance["rows"][1]["elements"][0]["distance"]["value"] / 1000,
        "comingBackDuration": distance["rows"][1]["elements"][0]["duration"]["value"],
        "totalDistance": distance["rows"][0]["elements"][1]["distance"]["value"] / 1000 + distance["rows"][1]["elements"][0]["distance"]["value"] / 1000,
        "freeDistance": freeDistance,
        "excessDistance": excessDistance,
        "excessPrice": excessPrice,
        "additionnalPrice": additionnalPrice}, :ok)
	end

	private

	def check_params
		!params[:address] ||
      !params[:city] ||
      !params[:postal] ||
      !params[:province]
	end


	def query_builder(param)
		param = "%" + param.gsub(/[\s]/, "% %") + "%"
		filters = param.split(' ')
		and_a = []
		query = "Select * from Address Where "
		filters.each do |fil|
			and_a.push("address LIKE '#{fil}' OR city LIKE '#{fil}' OR postal LIKE '#{fil}' OR province LIKE '#{fil}'")
		end
		and_length = and_a.length
		and_a.each.with_index do |fil,i|
			index = i +1
			if index == and_length
				query += fil
			else
				query += "#{fil} OR"
			end
		end
		query += "AND #{where}"
		return query
	end

	def check_address(distance)
		distance["rows"] && distance["rows"].length == 2 && distance["rows"][0]["elements"] && distance["rows"][0]["elements"][1]["status"] == "OK"
	end
end
