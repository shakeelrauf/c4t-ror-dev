class Api::V1::QuickQuoteController < ApiController

  # def index
  #   # QuickQuote class not found
  # 	quickquotes = QuickQuote.includes(:user, :heardofus).all
	#   return render_json_response(quickquotes, :ok)
  # end

   # The save a of a quote
  def save_quotes
    # Validate body data before insert.
    if (!params[:firstName].present? || !params[:lastName].present? || !params[:postal].present? || !params[:heardofus].present? || !params[:phone].present?)
      return render_json_response({:error => "Please send all required customer attributes."}, :bad_request)
		else
      postal_code = IsValid.postal(params[:postal])
      if (postal_code.length != 7)
      	return render_json_response({:error => "The postal code seems invalid."}, :bad_request)
      end
      phone = ""
      i = 0
      while i < params[:phone].length
        if ((params[:phone][i].to_i).kind_of? Integer)
          phone += params[:phone][i]
        end
        i = i+1
      end
      if (phone.length < 10)
      	return render_json_response({:error => "phone number length must be at least 10 digits."}, :bad_request)
      end
      carList = nil
      begin
        carList = JSON.parse(params[:cars].to_json)
      rescue
      	return render_json_response({:error => "The cars cannot be parsed"}, :bad_request)
      end
      @heard_of_us = Heardofus.find_or_initialize_by(type: params[:heardofus])
      if @heard_of_us.new_record?
        Heardofus.create(type: params[:heardofus])
      end
      @client = Customer.custom_upsert({idHeardOfUs: @heard_of_us.id,phone: phone,firstName: params[:firstName],lastName: params[:lastName]},{phone: phone})
      @quote = Quote.where("dtCreated <= ?" , DateTime.now.strftime("YYYY-MM-DD 00:00:00"))
      counter = @quote.count
      quote = Quote.custom_upsert({note: "",idUser: current_user.present? ? current_user.idUser : nil ,idClient: @client.id},{idQuote: params[:quote]})
      carList.each do |car, val|
        if (carList[car]["car"] == "")
          return respond400Message({:error => "The type of vehicle was not selected"}, :bad_request)
        elsif (carList[car]["missingWheels"] == "")
          return respond400Message({:error => "The missing wheels was not selected"}, :bad_request)
        elsif (carList[car]["missingBattery"] == "")
          return respond400Message({:error => "The missing battery was not selected: [" + carList[car]["missingBattery"] + "]"}, :bad_request)
        elsif (carList[car]["addressId"] == "" && carList[car]["carPostal"] == "")
          return respond400Message({:error => "The address was not selected properly"}, :bad_request)
        end
        updateCarForAddress(carList[car], @client)
      end
  		r_quote = Quote.includes(:quote_car, :customer).where(idQuote: quote.id).first.to_json(include: [:quote_car, :customer])
			return render_json_response(r_quote, :ok)
		end
	end

  def updateCarForAddress(car, client)
     # If the addressId is an int, it's an addressId, else it's a postal
    addressId = car["idAddress"].nil? ? car["idAddress"] : car["idAddress"].to_i
    if addressId.kind_of? Integer
      # It's a number
      updateQuoteCar(car, addressId.to_i)

    elsif (!car["carPostal"])
       # No address at this time
      updateQuoteCar(car, nil)

    elsif (car["carPostal"] && car["carPostal"] != "")
       # We can create a new address
      @address = Address.create(
          idClient: client.id,
          address:  car["carStreet"],
          city:     car["carCity"],
          postal:   car["carPostal"],
          province: car["carProvince"],
          distance: car["distance"]
      )
        updateQuoteCar(car, @address.id)
    end
  end

   # The update of a quote car
  def updateQuoteCar(car, addressId)
    @quote_car = QuoteCar.find_by_id(car["car"])
    @quote_car.update(
        idAddress: addressId,
        missingWheels: car["missingWheels"].present? ? car["missingWheels"].to_i : 0,
        missingBattery: (car["missingBattery"] && car["missingBattery"] == 1),
        missingCat: (car["missingCat"] && car["missingCat"] == 1),
        gettingMethod: car["gettingMethod"],
        distance: (car["distance"].present? ? car["distance"].to_f : nil),
        price: (car["price"].present? ? car["price"].to_f : nil)
    )
  end

  def respond400Message(res, msg)
    render json: res.to_json, msg: msg, adapter: :json_api
  end

end
