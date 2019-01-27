class VehiclesController < ApplicationController
  def show
    vehicle = VehicleInfo.where(idVehiculeInfo: params[:no]).first
    respond_json(vehicle)
  end

  def partial
    car = QuoteCar.includes([:information, :address]).where(idQuoteCars: params[:car]).first
    render partial: 'quotes/vehicle_parameters', locals: {car: car, vehicle: car.information}
  end
end
