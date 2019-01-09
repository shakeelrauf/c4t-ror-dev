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