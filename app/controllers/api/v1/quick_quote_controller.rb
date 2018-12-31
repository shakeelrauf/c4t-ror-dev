class Api::V1::QuickQuoteController < ApiController
	
	def updateCarForAddress(car, client, next) {
     # If the addressId is an int, it's an addressId, else it's a postal
    addressId = car.carAddressId.to_i

    if addressId.kind_of? Integer
      # It's a number
      updateQuoteCar(car, addressId.to_i, next);

    elsif (!car.carPostal)
       # No address at this time
      updateQuoteCar(car, nil, next);

    elsif (car.carPostal && car.carPostal != "")
       # We can create a new address
      @address = Address.create(
          idClient: client.id,
          address:  car.carStreet,
          city:     car.carCity,
          postal:   car.carPostal,
          province: car.carProvince,
          distance: car.distance
      )
        updateQuoteCar(car, @address.id, next);
    end
  end

   # The update of a quote car
  def updateQuoteCar(car, addressId, next)
    console.log("==================> QuoteCar.update    : " + JSON.stringify(car));
    console.log("==================> QuoteCar.update    : " + parseInt(car.car));
    QuoteCar.update(
        idAddress: addressId,
        missingWheels: car.missingWheels.present? ? car.missingWheels.to_i : 0,
        missingBattery: (car.missingBattery && car.missingBattery == 1),
        missingCat: (car.missingCat && car.missingCat == 1),
        gettingMethod: car.gettingMethod,
        distance: (car.distance.present? ? car.distance.to_f : nil),
        price: (car.price.present? ? car.price.to_f : nil)
    )
    next();
  end

  def index
  	quickquotes = QuickQuote.all.includes(:User, :HeardOfUs)
			return render_json_response(quickquotes, :ok)
  #   QuickQuote.findAll({
  #     include: [{
  #       model: User,
  #       as: "dispatcher"
  #     }, {
  #       model: HeardOfUs,
  #       as: "heardofus"
  #     }]
  #   }).then(quickquotes => {
  #     res.json(quickquotes);
  #   });
  end


   # The save a of a quote
  def save_quotes

      # Validate body data before insert.
      if (params[:firstName] == nil || params[:lastName] == nil || params[:postal] == nil || !params[:heardofus] || params[:phone] == nil) 
        return render_json_response({:error => "Please send all required customer attributes."}, :bad_request)
			else
        params[:postal] = IsValid.postal(params[:postal]);
        if (params[:postal].length < 6 || params[:postal] > 7)
        	return render_json_response({:error => "The postal code seems invalid."}, :bad_request)
        end
         # Parse validate the phone number
        phone = "";
        params[:phone].each_with_index do |phone, index|
          if ((phone[index].to_i).kind_of? Integer)
            phone += phone[i];
        	end
        end
        if (phone.length < 10)
        	return render_json_response({:error => "phone number length must be at least 10 digits."}, :bad_request)
        end
         # Parse the cars
        carList = nil;
        begin  # "try" block
          carList = JSON.parse(params[:cars]);
        rescue(e) # optionally: `rescue Exception => ex`
        	return render_json_response({:error => "The cars cannot be parsed"}, :bad_request)
        end
        
        @heard_of_us = HeardOfUs.find_or_initialize_by(type: params[:heardofus])
		      if @heard_of_us.new_record?
		      	HeardOfUs.create(type: params[:heardofus])
		      end

            @client = Client.customUpsert({idHeardOfUs: @heard_of_us.id,phone: phone,firstName: params[:firstName],lastName: params[:lastName]},{phone: phone})
            @quote = Quote.where(dtCreated: {[Op.gte]: moment().format("YYYY-MM-DD") + " 00:00:00"})
            counter = @quote.count

            quote = Quote.customUpsert({reference: moment().format("YYMM") + (Number(counter) + 1).toString().padStart(4, "0"),note: "",idUser: req.user.idUser,idClient: @client.id},{id: params[:quote]})
                   # Save each car                  
        	carList.each do |car, next|

            if (car.car == "")
							return render_json_response({:error => "The type of vehicle was not selected"}, :bad_request)
            elsif (car.missingWheels == "")
							return render_json_response({:error => "The missing wheels was not selected"}, :bad_request)
            elsif (car.missingBattery == "")
							return render_json_response({:error => "The missing battery was not selected: [" + car.missingBattery + "]"}, :bad_request)
            elsif (car.addressId == "" && car.carPostal == "")
							return render_json_response({:error => "The address was not selected properly"}, :bad_request)
          	end

            updateCarForAddress(car, client, next);
          end
    		r_quote = Quote.find(quote.id).includes(:QuoteCar, :Client)
				return render_json_response(r_quote, :ok)
			end
		end

  def respond400Message(res, msg) {
		return render_json_response(msg, :bad_request)
  end
end