class QuotecarsController < ApplicationController
		# before_action :authenticate_user

	def quotescars
		list = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]])
 	end

 	def show
 		qc = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuoteCars: params[:carNo]).first
 	end

 	def create_car
 		@car = VehicleInfo.create(year: params[:years], make: params[:make], model: params[:model], trim: params[:trim], body: params[:body], drive: params[:drive], transmission: params[:transmission], seats: params[:seats],doors: params[:doors], weight: params[:weight])
 		if @car.save
 			redirect_to "/cars"
 		end
 	end

 	def list_cars
 		@cars = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).all
 	end
end