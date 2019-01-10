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
    redirect_to "/cars"
 	end

 	def list_cars
 		@cars = ApiCall.get("/cars",{}, headers)
 	end

 	def car_count
    vehicle = ApiCall.get("/vehicles/#{params[:offset]}", {}, headers)
    respond_json(vehicle)
 	end

 	def search_cars
 		if params[:filter] != ""
	 		vehicles = ApiCall.get("/vehicles?filter=#{params[:filter]}&offset=#{params[:offset]}", {},headers)
	    returned = {}
	    returned[:results] = vehicles
	    returned[:pagination] = {}
	    if(vehicles.length != 30)
	      returned[:pagination][:more] = false
	    else
	      returned[:pagination][:more] = true
	    end
	    respond_json(returned)
	  else
 			vehicles = ApiCall.get("/cars?filter=#{params[:filter]}&offset=#{params[:offset]}",{}, headers)
 			groups = []
	 		vehicles.each do |vehicle|
	 			groups << vehicle["information"]
	    end
 			returned = {}
	    returned[:results] = groups
	    returned[:pagination] = {}
	    if(groups.length != 30)
	      returned[:pagination][:more] = false
	    else
	      returned[:pagination][:more] = true
	    end
	    respond_json(returned)
	  end
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