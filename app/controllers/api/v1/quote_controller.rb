class Api::V1::QuoteController < ApiController
	# before_action :authenticate_user
  include ActionView::Helpers::NumberHelper

    # Creates a blank quote car
  def create_car
    @car = QuoteCar.create(
      idQuote: params[:quote],
      idCar: params[:veh],
      missingWheels: 0,
      missingBattery: nil,
      missingCat: nil,
      gettingMethod: "pickup",
    )
	  return render_json_response(@car, :ok)	 	
  end

    # Creates a blank quote
  def create
    # Find the last settings
    # Copy them in the quote for now
    	
    settings = db.query("SELECT * FROM Settings WHERE dtCreated IN (SELECT MAX(dtCreated) FROM Settings GROUP BY name)", {
      type: db.QueryTypes.SELECT
    })

    # The settings hash
    s = {}
    settings.each do |setting|
      s[setting.name] = setting.value
    end

    count = Quote.where(dtCreated: moment().format("YYYY-MM-01 00:00:00"))
      reference = moment().format("YYMM") + ("0000" + (count + 1)).slice(-4)
      quote = Quote.create(
        idUser: current_user.idUser,
        reference: reference,
        smallCarPrice: s.smallCarPrice,
        midCarPrice: s.midCarPrice,
        largeCarPrice: s.largeCarPrice,
        steelPrice: s.steelPrice,
        wheelPrice: s.wheelPrice,
        catPrice: s.catalysorPrice,
        batteryPrice: s.batteryPrice,
        excessCost: s.excessPrice,
        freeDistance: s.freeDistance,
        pickup: s.pickup
      )
 		 return render_json_response(quote, :ok)

  end

  # Creates a blank quote ca
  def remove_car
  	@quote_car = QuoteCar.where(id: params[:car])
    @quote_car.destroy
    return render_json_response({:msg => "ok"}, :ok)
  end

  def retrive_car
  	@quote_car = QuoteCar.find_by_id(params[:carNo])
    return render_json_response(@quote_car, :ok)
  end

  # delete a quote
	def destroy
    # delete a quote
  	@quote = Quote.where(id: params[:no])
  	@quote.destroy
    return render_json_response({:message => "Quote deleted!"}, :ok)
	end

	# Get all possible status.
  def all_status
	  status = Status.all
	  return render_json_response(status, :ok)	
  end

# .to_json(include: {:customer => {:include => :address}})
  # Get all possible quotes.
  def all_quotes  
    quotes = Quote.includes(:status, customer: [:address]).all.to_json(include: [:status, :customer => {:include => :address}])
    status = Status.all
    # data = [quotes]
    data = []
    JSON.parse(quotes).each do |q|
      json_quote = q
      json_quote["customer"]["fullName"] = q["customer"]["firstName"] + " " + q["customer"]["lastName"]  if json_quote["customer"].present?
      json_quote["customer"]["address"] = q["customer"]["address"][0]["address"]+ ", "+q["customer"]["address"][0]["city"]+ ", "+q["customer"]["address"][0]["province"]  if q["customer"].present? && q["customer"]["address"].present?
      data.push(json_quote)
    end

    quotez = {
       "msg": "Success!!",
       "success": true,
       "data": data,
       "status": status
    }

    return render json: quotez.to_json, status: :ok 
  end

  # get one quote
  def quote
  	@quote = Quote.includes(:user, :status, :client => [:address, :heardofus]).find_by_id(id: params[:no]).to_json(include: [:dispatcher,:status, {customer: {:include => [:address, :heardofus]}}])
	  if (!@quote)
			return render_json_response({:message => "Quote not found!"}, :ok)
	  else
	    @quote_car = QuoteCar.includes(:address).where(idQuote: params[:no]).to_json(include: [:address])
	    @quote.dataValues.cars = @quote_car
			return render_json_response(@quote, :ok)
		end
	end

  def update_quote
    if (!params[:cars] || params[:note].class.to_s != "NilClass" )
      return render_json_response({:error => "please send all require attributes."}, :ok)
    else
      @quote = Quote.find_by_id(id: params[:no])
      quote = @quote.update(note: params[:note])
        # Update all cars of quote.
      params[:car].each do |car|
        gettingMethod = (car.dropoff.class.to_s != "NilClass" ? "pickup" : "dropoff")
        if (car.missingParts.class.to_s != "NilClass" )
          car.missingParts = "[]"
        end
        cars = QuoteCar.where(idCar: car.id, idQuote: params[:no])
        vehicle = cars.update(
          missingParts: car.missingParts.to_s,
          donation: car.donation,
          gettingMethod: gettingMethod,
          flatBedTruckRequired: car.flatBedTruckRequired)
      end
      updatedQuote = Quote.find_by_id(id: params[:no])
      if (!updatedQuote)
        return render_json_response({:error => "Quote not found!"}, :ok)
      else
        return render_json_response(updatedQuote, :ok)
      end
    end
  end

  def update_status
    if (!params[:status] && !params[:id])
      return render_json_response({"msg": "Failure!!", "success": false,:error => "please send attribute status."}, :ok)
    else
      @quote = Quote.includes(:status).where(idQuote: params[:id])
      if !@quote.present?
        return render_json_response({"msg": "Failure!!", "success": false,:error => "Quote not found"}, :ok)
      else
        stats = Status.where(idStatus: params[:status])
        if params[:status] && stats.present?
          result = @quote.update(
            idStatus: params[:status],
            dtStatusUpdated: Time.now
          )
        else
          return render_json_response({"msg": "Failure!!", "success": false,:error => "Status not found"}, :ok)
        end
        r_quote = Quote.includes(:customer).find_by_id(id: params[:no])
        # If status is «in Yard», send sms to customer for know his appreciation.
        if (params[:status] == 6)
          # Check if sms already sent.
          if (!r_quote.isSatisfactionSMSQuoteSent && r_quote.customer.cellPhone)
            sms = TwilioTextMessenger.new "Hello. This is CashForTrash. We recently bought your car. We want to know your satisfaction. On a scale of 1 to 10, how much did you appreciate our service? Please respond with a number.", "4388241370"
            sms.call
            quotes.update(isSatisfactionSMSQuoteSent: 1)
          end
        end

        quotez = {
           "msg": "Success!!",
           "success": true,
           "data": result
        }
        return render_json_response(quotez, :ok)
      end
    end
  end

  def update_quote_status
    if (!params[:status])
      return render_json_response({:error => "please send attribute status."}, :ok)
    else
      quotes = Quote.includes(:customer).find_by_id(id: params[:no])
      if quotes.present?
        results = quotes.update(
          idStatus: params[:status],
          dtStatusUpdated: Time.now
        )
      end
      r_quote = Quote.includes(:customer).find_by_id(id: params[:no])
      # If status is «in Yard», send sms to customer for know his appreciation.
      if (params[:status] == 6)
        # Check if sms already sent.
        if (!r_quote.isSatisfactionSMSQuoteSent && r_quote.customer.cellPhone)
          sms = TwilioTextMessenger.new "Hello. This is CashForTrash. We recently bought your car. We want to know your satisfaction. On a scale of 1 to 10, how much did you appreciate our service? Please respond with a number.", "4388241370"
          sms.call
          quotes.update(isSatisfactionSMSQuoteSent: 1)
        end
      end

      return render_json_response({:message => "Quote status updated!"}, :ok)
    end
  end

  # Get all quotes of a particular customer.
  def particular_customer_quotes
    offset = 0
    filter = "%"
    if (params[:offset].class.to_s != "NilClass"  && params[:offset].integer?)
      offset = params[:offset].to_i
    end
    if (params[:filter].class.to_s != "NilClass")
      filter = "%" + params[:filter] + "%"
    end
    lstQuotes = Quote.includes(:dispatcher, :customer, :status).where("(note LIKE ?  OR status.name LIKE ? OR dispatcher.firstName LIKE ? OR dispatcher.lastName LIKE ? OR reference  LIKE ? ) AND idClient = ?", filter, filter, filter, filter, filter, params[:no]).order('DESC').offset(offset).limit(30)

    lstQuotes.each do |quote|
      # TODO! Format each quote before send it.
    end
      return render_json_response(lstQuotes, :ok)
  end


  def particular_customer_quotes_by_filters
    # Get all quotes made by particular user with filter.
    offset = 0
    filter = "%"
    if (params[:offset].class.to_s != "NilClass"  && params[:offset].integer?)
      offset = params[:offset].to_i
    end
    if (params[:filter].class.to_s != "NilClass")
      filter = "%" + params[:filter] + "%"
    end
    lstQuotes = Quote.includes(:dispatcher, :customer, :status).where("(customer.firstName LIKE ?  OR customer.lastName LIKE ? OR customer.phone LIKE ? OR customer.extension LIKE ? OR customer.type  LIKE ?OR customer.email LIKE ? OR customer.cellPhone LIKE ? OR customer.secondaryPhone LIKE ? OR customer.note  LIKE ? OR customer.grade  LIKE ? OR note LIKE ? OR reference  LIKE ? OR status.name  LIKE ? ) AND idClient = ?", filter, filter, filter, filter, filter, filter, filter, filter, filter, filter, filter, filter, filter, params[:no]).order('DESC').offset(offset).limit(30)

    lstQuotes.each do |quote|
      # TODO! Format each quote before send it.
    end
      return render_json_response(lstQuotes, :ok)
  end
end