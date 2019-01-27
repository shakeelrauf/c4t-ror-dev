class QuotecarsController < ApplicationController
  before_action :login_required
	include Quotecarsmethods

	def quotescars
		list = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]])
 	end

 	def show
 		qc = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuoteCars: params[:carNo]).first
 	end

 	def create_car
    car = VehicleInfo.create(car_params)
    redirect_to carz_path(params: {weight: car["weight"]})
 	end

 	def index
		cars, count = vehicles_search 15
		render :index, locals: {pages: count, cars: cars}
 	end

 	def car_count
    vehicle = ApiCall.get("/vehicles/#{params[:offset]}", {}, headers)
    respond_json(vehicle)
 	end

 	def search_cars
		params[:filter] = params[:filter].gsub("?","")
		params[:limt] = params[:limit].gsub("?","")
		params[:offset] = params[:offset].gsub("?","")
		vehicles, count = vehicles_search params[:limit], params[:offset], params[:filter]
		result = {count: count, results: vehicles}
		respond_json(result)
 	end

	def car_params
    params.permit(:year, :make, :model, :trim, :body, :drive, :transmission, :seats, :doors, :weight)
  end
end