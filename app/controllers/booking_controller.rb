class BookingController < ApplicationController
  before_action :login_required


  def book
    quote =  ApiCall.get("/quotes/#{params[:no]}", {}, headers)
    cars =  ApiCall.get("/quotes/#{params[:no]}/cars",{},headers)
    respond_json({error: "Car list is empty please select a car"}) if cars.empty?
    charities =  ApiCall.get("/charities",{}, headers)
    heardofus =  ApiCall.get("/heardsofus", {}, headers)
    cars_formated = []
    cars.length.times do |i|
      cars_formated.push(cars[i]["information"])
      cars_formated[i]["vehicle"] = cars[i]["information"]
      cars_formated[i]["id"] = cars[i]["idQuoteCars"]
      cars_formated[i]["donation"] = cars[i]["donation"]
      cars_formated[i]["gettingMethod"] = cars[i]["gettingMethod"]
      cars_formated[i]["flatBedTruckRequired"] = cars[i]["flatBedTruckRequired"]
      cars_formated[i]["gotKeys"] = cars[i]["gotKeys"]
      cars_formated[i]["drivetrain"] = cars[i]["drivetrain"]
      cars_formated[i]["tiresCondition"] = cars[i]["tiresCondition"]
      cars_formated[i]["ownership"] = cars[i]["ownership"]
      cars_formated[i]["running"] = cars[i]["running"]
      cars_formated[i]["complete"] = cars[i]["complete"]
      cars_formated[i]["color"] = cars[i]["color"]
      cars_formated[i]["receipt"] = cars[i]["receipt"]
      cars_formated[i]["vin"] = cars[i]["vin"]
      cars_formated[i]["ownershipName"] = cars[i]["ownershipName"]
      cars_formated[i]["ownershipAddress"] = cars[i]["ownershipAddress"]
      cars_formated[i]["cashRegular"] = cars[i]["cashRegular"]
      cars_formated[i]["timeBooked"] = cars[i]["timeBooked"]
      cars_formated[i]["dateBooked"] = cars[i]["dateBooked"]
      cars_formated[i]["carNotes"] = cars[i]["carNotes"]
      cars_formated[i]["driverNotes"] = cars[i]["driverNotes"]
    end
    locals =  {
        user: current_user,
        quote: quote,
        cars: cars_formated,
        charities: charities,
        heardsofus: heardofus,
    }
    render  locals: locals
  end

  def booking
    booking = ApiCall.post("/booking", JSON.parse(params.to_json), headers)
    return respond_json({eror: booking["error"]}) if booking["error"]
    respond_json({message: "Booking Saved."})
  end
end
