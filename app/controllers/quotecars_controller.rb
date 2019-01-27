class QuotecarsController < ApplicationController
  before_action :login_required
	include Quotecarsmethods

	def quotescars
		list = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]])
 	end

 	def show
 		qc = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuoteCars: params[:id]).first
 	end

 	def create
    car = VehicleInfo.create(car_params)
    flash[:success] = 'Car is successfully Created!'
    redirect_to cars_path
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