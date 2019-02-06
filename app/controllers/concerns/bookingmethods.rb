module Bookingmethods
  def update_booking(params)
    params.each do |key,value|
      if key.match(/^vin+/)
        id  =  key.split('-')[1]
        date  = params["dateBooked-#{id}"] == '' ? nil : params["dateBooked-#{id}"]
        cash  = params["cashRegular-#{id}"] == '' ? nil : params["cashRegular-#{id}"]

        comp  = params["complete-#{id}"] == nil ? nil : (params["complete-#{id}"] == '1')
        runn  = params["running-#{id}"] == nil ? nil : (params["running-#{id}"] == '1')
        own   = params["ownership-#{id}"] == nil ? nil : (params["ownership-#{id}"] == '1')
        keys  = params["gotKeys-#{id}"] == nil ? nil : (params["gotKeys-#{id}"] == '1')
        tow   = params["isTowable-#{id}"] == nil ? nil : (params["isTowable-#{id}"] == '1')
        twowd = params["canDo2wd-#{id}"] == nil ? nil : (params["canDo2wd-#{id}"] == '1')
        neut  = params["canGoNeutral-#{id}"] == nil ? nil : (params["canGoNeutral-#{id}"] == '1')
        plates_on  = params["plates_on-#{id}"] == nil ? nil : (params["plates_on-#{id}"] == '1')
        cars = QuoteCar.where(idQuoteCars: id).first
        return respond_json({error: "Booking cant be Saved."}) if cars.nil?
        cars.update(gotKeys: keys,drivetrain: params["drivetrain-#{id}"],tiresCondition: params["tiresCondition-#{id}"],
                    ownership: own,running: runn,complete: comp,isTowable: tow,canDo2wd: twowd,canGoNeutral: neut,
                    color: params["color-#{id}"],receipt: params["receipt-#{id}"],vin: params["vin-#{id}"],
                    ownershipName: params["ownershipName-#{id}"],ownershipAddress: params["ownershipAddress-#{id}"],
                    cashRegular: cash,timeBooked: params["timeBooked-#{id}"],dateBooked: date,
                    carNotes: params["carNotes-#{id}"],driverNotes: params["driverNotes-#{id}"],
                    payment_method: params["payment_method-#{id}"],customer_email: params["customer_email-#{id}"], platesOn: plates_on)
      end
    end
    return respond_json({message: "Booking Saved."})
  end
end