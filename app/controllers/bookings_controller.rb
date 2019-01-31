class BookingsController < ApplicationController
  before_action :login_required
  include Bookingmethods

  def book
    quote =  Quote.where(idQuote:  params[:id]).first
    respond_json({error: "Car list is empty please select a car"}) if quote.nil?
    cars =  quote.quote_car
    respond_json({error: "Car list is empty please select a car"}) if cars.empty?
    charities =  Charitie.all
    heardofus =  Heardofus.all
    cars_formated = []
    cars.each.with_index do |car,i|
      cars_formated.push(JSON.parse car.information.to_json)
      cars_formated[i]["vehicle"] = car.information
      cars_formated[i]["id"] = car.idQuoteCars
      cars_formated[i]["donation"] = car.donation
      cars_formated[i]["gettingMethod"] = car.gettingMethod
      # cars_formated[i]["flatBedTruckRequired"] = car.flatBedTruckRequired
      cars_formated[i]["gotKeys"] = car.gotKeys
      cars_formated[i]["drivetrain"] = car.drivetrain
      cars_formated[i]["tiresCondition"] = car.tiresCondition
      cars_formated[i]["ownership"] = car.ownership
      cars_formated[i]["running"] = car.running
      cars_formated[i]["complete"] = car.complete
      cars_formated[i]["color"] = car.color
      cars_formated[i]["receipt"] = car.receipt
      cars_formated[i]["vin"] = car.vin
      cars_formated[i]["ownershipName"] = car.ownershipName
      cars_formated[i]["ownershipAddress"] = car.ownershipAddress
      cars_formated[i]["cashRegular"] = car.cashRegular
      cars_formated[i]["timeBooked"] = car.timeBooked
      cars_formated[i]["dateBooked"] = car.dateBooked
      cars_formated[i]["carNotes"] = car.carNotes
      cars_formated[i]["driverNotes"] = car.driverNotes
    end
    locals =  {user: current_user, quote: quote, cars: cars_formated, charities: charities, heardsofus: heardofus}
    render :show, locals: locals
  end

  def create
    booking = update_booking(params)
  end
end