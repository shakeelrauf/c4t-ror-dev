class QuotecarsController < ApplicationController
  	before_action :login_required

	def quotescars
		list = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]])
 	end

 	def show
 		qc = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuoteCars: params[:carNo]).first
 	end

 	def create_car
    @car = ApiCall.post("/vehicles", form_body(params), headers )
    redirect_to carz_path(params: @car)
 	end

 	def list_cars
 		@cars = ApiCall.get("/vehicles?limit=15",{}, headers)
		count =  ApiCall.get("/vehicles/count?limit=15",{}, headers)
		render locals: {pages: count}
 	end

 	def car_count
    vehicle = ApiCall.get("/vehicles/#{params[:offset]}", {}, headers)
    respond_json(vehicle)
 	end

 	def search_cars
		params[:filter] = params[:filter].gsub("?","")
		params[:limt] = params[:limit].gsub("?","")
		params[:offset] = params[:offset].gsub("?","")
		vehicles = ApiCall.get("/vehicles?filter=#{params[:filter]}&offset=#{params[:offset]}&limit=#{params[:limit]}", {},headers)
		count =  ApiCall.get("/vehicles/count?filter=#{params[:filter]}&limit=#{params[:limit]}",{}, headers)
		result = {
				count: count,
				results: vehicles
		}
		puts "-----------------------------------------------------------------------#{vehicles.length}"

		respond_json(result)
 	end

	def form_body(params)
    {
      "year":      					params[:year],
      "make": 		 					params[:make],
      "model": 		 					params[:model],
      "trim": 	 	 					params[:trim],
      "body": 		 					params[:body],
      "drive": 		 					params[:drive],
      "transmission": 	 	  params[:transmission],
      "seats": 		 					params[:seats],
      "doors": 	 	  				params[:doors],
      "weight": 		 				params[:weight]
    }
  end
end