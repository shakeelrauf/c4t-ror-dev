class BookingController < ApplicationController
  before_action :login_required


  def book
    quote =  ApiCall.get("/quotes/#{params[:no]}", {}, headers)
    cars =  ApiCall.get("/quotes/#{params[:no]}/cars",{},headers)
    charities =  ApiCall.get("/charities",{}, headers)
    heardofus =  ApiCall.get("/heardsofus", {}, headers)
    carsFormated = []
    cars.length.times do |i|
      carsFormated.push(cars[i]["information"])
      carsFormated[i]["vehicle"] = cars[i]["information"]
      carsFormated[i]["id"] = cars[i]["idQuoteCars"]
      carsFormated[i]["donation"] = cars[i]["donation"]
      carsFormated[i]["gettingMethod"] = cars[i]["gettingMethod"]
      carsFormated[i]["flatBedTruckRequired"] = cars[i]["flatBedTruckRequired"]
      carsFormated[i]["gotKeys"] = cars[i]["gotKeys"]
      carsFormated[i]["drivetrain"] = cars[i]["drivetrain"]
      carsFormated[i]["tiresCondition"] = cars[i]["tiresCondition"]
      carsFormated[i]["ownership"] = cars[i]["ownership"]
      carsFormated[i]["running"] = cars[i]["running"]
      carsFormated[i]["complete"] = cars[i]["complete"]
      carsFormated[i]["color"] = cars[i]["color"]
      carsFormated[i]["receipt"] = cars[i]["receipt"]
      carsFormated[i]["vin"] = cars[i]["vin"]
      carsFormated[i]["ownershipName"] = cars[i]["ownershipName"]
      carsFormated[i]["ownershipAddress"] = cars[i]["ownershipAddress"]
      carsFormated[i]["cashRegular"] = cars[i]["cashRegular"]
      carsFormated[i]["timeBooked"] = cars[i]["timeBooked"]
      carsFormated[i]["dateBooked"] = cars[i]["dateBooked"]
      carsFormated[i]["carNotes"] = cars[i]["carNotes"]
      carsFormated[i]["driverNotes"] = cars[i]["driverNotes"]
    end
    locals =  {
        user: current_user,
        quote: quote,
        cars: carsFormated,
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
