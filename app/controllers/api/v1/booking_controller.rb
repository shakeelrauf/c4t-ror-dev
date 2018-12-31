class Api::V1::BookingController < ApiController
  before_action :authenticate_user
  
	def update
		car_id  = booking_params.keys.select { |key| key.to_s.match(/^vin+/) }
		if car_id
			# rWe have found a car id!
			id = car_id.split('-')[1]
			puts("=======> Saving booking for carId: #{id}")

    	date  = booking_params["dateBooked-#{id}"] == '' ? nil : booking_params["dateBooked-#{id}"]
    	cash  = booking_params["cashRegular-#{id}"] == '' ? nil : booking_params["cashRegular-#{id}"]

      comp  = booking_params["complete-#{id}"] == nil ? nil : (booking_params["complete-#{id}"] == '1')
      runn  = booking_params["running-#{id}"] == nil ? nil : (booking_params["running-#{id}"] == '1')
      own   = booking_params["ownership-#{id}"] == nil ? nil : (booking_params["ownership-#{id}"] == '1')
      keys  = booking_params["gotKeys-#{id}"] == nil ? nil : (booking_params["gotKeys-#{id}"] == '1')
      tow   = booking_params["isTowable-#{id}"] == nil ? nil : (booking_params["isTowable-#{id}"] == '1')
      twowd = booking_params["canDo2wd-#{id}"] == nil ? nil : (booking_params["canDo2wd-#{id}"] == '1')
      neut  = booking_params["canGoNeutral-#{id}"] == nil ? nil : (booking_params["canGoNeutral-#{id}"] == '1')

      cars = QuoteCar.where(idQuoteCars: id).first
      if cars.update({
          gotKeys: keys,
          drivetrain: booking_params["drivetrain-#{id}"],
          tiresCondition: booking_params["tiresCondition-#{id}"],
          ownership: own,
          running: runn,
          complete: comp,
          isTowable: tow,
          canDo2wd: twowd,
          canGoNeutral: neut,
          color: booking_params["color-#{id}"],
          receipt: booking_params["receipt-#{id}"],
          vin: booking_params["vin-#{id}"],
          ownershipName: booking_params["ownershipName-#{id}"],
          ownershipAddress: booking_params["ownershipAddress-#{id}"],
          cashRegular: cash,
          timeBooked: booking_params["timeBooked-#{id}"],
          dateBooked: date,
          carNotes: booking_params["carNotes-#{id}"],
          driverNotes: booking_params["driverNotes-#{id}"]
        })
      	return render_json_response({:message => BOOKING, :success => true}, :ok)
      else
      	return render_json_response({:errors => BOOKING_FAILED, :success => false}, :unprocessable_entity)
      end
		else
      return render_json_response({:errors => BOOKING_FAILED, :success => false}, :unprocessable_entity)
    end
	end

	protected
	def booking_params
		params
	end
end
