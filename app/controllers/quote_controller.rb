class QuoteController < ApplicationController
  before_action :login_required
  include Quotesmethods

	def all_quotes  
    @quotes = Quote.eager_load(:customer, :dispatcher,:status).all
    @pages = 0
    if @quotes.count % 15 > 0
      @pages = 1
    end
    @pages += (@quotes.count / 15).ceil
    @quotes = @quotes.limit(15).offset(0)
    @status = Status.all
  end

  def car_price
    return respond_json({"netPrice": nil}) if params[:missingWheel] == "" || params[:missingBattery] == "" || params[:missingCat] == ""
    quote = JSON.parse Quote.includes(:dispatcher,customer: [:address,:heardofus]).where(idQuote: params[:quoteId]).first.to_json(include: [:dispatcher,{:customer => {include: [:address, :heardofus]}}])
    return respond_json({"netPrice": nil}) if quote.nil?
    cars = JSON.parse QuoteCar.where(idQuote: params[:no]).to_json
    quote["cars"] = cars
    car_distance =  params[:distance]
    car_distance = car_distance.to_i if car_distance.present?
    excessDistance = 0.0
    excessDistance = [car_distance- quote["freeDistance"].to_i, 0.0 ].max if car_distance.present? && car_distance != "NOT_FOUND" && car_distance != "ZERO_RESULTS"
    pickupCost    = quote["pickup"].to_f
    isPickup      = (params[:gettingMethod] == "pickup")
    excessCost    = isPickup ? quote["excessCost"].to_f : 0.0
    distanceCost  = excessDistance * excessCost
    weightPrice   = params[:weight].to_f / 1000.0 * quote["steelPrice"].to_f
    dropoff = weightPrice
    dropoff -=  params[:missingWheels].to_i * quote["steelPrice"].to_f
    dropoff -=  params[:missingCat].to_i * quote["catPrice"].to_f
    dropoff -=  params[:missingBattery].to_i * quote["batteryPrice"].to_f
    dropoffPrice = [dropoff,0.0].max
    pickupPrice = 0.0
    if car_distance.present? && car_distance >  0.01 && excessDistance.present?
      pickupPrice = [(dropoffPrice - (excessDistance * quote["excessCost"].to_f) - pickupCost), 0.0].max
    end
    netPrice = (isPickup ? pickupPrice : dropoffPrice)
    r = {netPrice: netPrice,
         pickupPrice: pickupPrice,
         dropoffPrice: dropoffPrice
    }
    r[:weight] =  params[:weight].to_f / 1000.0
    r[:steelPrice] =  quote["steelPrice"].to_f
    r[:weightPrice] = weightPrice
    r[:distance] = car_distance.to_f
    r[:freeDistance] = quote["freeDistance"].to_f
    r[:excessDistance] = excessDistance.to_f
    r[:excessCost] =  excessCost.to_f
    r[:distanceCost] = -distanceCost.to_f
    r[:missingCatCost] = quote["catPrice"].to_f
    r[:missingBatCost] = quote["batteryPrice"].to_f
    r[:missingCat] = -(quote["catPrice"].to_f * params[:missingCat].to_f)
    r[:missingBat] = -(quote["batteryPrice"].to_f * params[:missingBattery].to_f)
    r[:missingWheelsCost] = quote["wheelPrice"].to_f
    r[:missingWheels] = -(quote["wheelPrice"].to_f * params[:missingWheels].to_f)
    r[:pickupCost] = quote["pickup"].to_f
    r[:carPrice] = netPrice.to_f
    respond_json(r)
  end

  def quote_with_filter
    res = ApiCall.get("/quotes/json?limit=#{params[:limit]}
      &offset=#{params[:offset]}&afterDate=#{params[:afterDate]}&beforeDate=#{params[:beforeDate]}&filter=#{params[:filter]}",{} , headers )
    respond_json(res)
  end

  def create_quote
    quickquote =  save_quotes
  end

  def vehicle_json
    vehicle = VehicleInfo.where(idVehiculeInfo: params[:no]).first
    respond_json(vehicle)
  end

  def vehicle_list
    vehicles = vehicles_search(params[:limit], params[:offset], params[:q])
    groups, item = [], {}
    vehicles.each do |vehicle|
      if vehicle["make"] == "Other"
        item["text"]= "Other"
      else
        item["text"] = vehicle["make"] + " " + vehicle["year"] + " " + vehicle["model"] + " " + vehicle["body"] + " " + vehicle["trim"] + " " + vehicle["transmission"] + " " + vehicle["drive"] + " " + vehicle["doors"] + " doors and " + vehicle["seats"] + " seats."
        item["id"] = vehicle["idVehiculeInfo"]
        created = false
        groups.length.times do |i|
          if groups[i]["text"] == vehicle["make"]
            groups[i]["children"].push(item)
            created = true
            break
          end
        end
        groups.push({text: vehicle["make"], children: [item]}) if !created
      end
    end
    # if !groups["#{vehicle.make}"]
    #   groups["#{vehicle.make}"] = vehicle.make
    #   groups["#{vehicle.make}"] = [item]
    # else
    #   groups["#{vehicle.make}"].push(item)
    # end
    returned = {}
    returned[:results] = groups
    returned[:pagination] = {}
    if(vehicles.length != 30)
      returned[:pagination][:more] = false
    else
      returned[:pagination][:more] = true
    end

    respond_json(returned)
  end

  def phone_list
    phones = Customer.where('phone LIKE ? OR cellPhone LIKE ? OR secondaryPhone LIKE ?', params[:search] + "%", params[:search] + "%", params[:search] + "%").limit(params[:limit].to_i).offset(params[:offset].to_i * params[:limit].to_i)
    #ApiCall.get("/client/phones?search=#{params[:search]}&limit=#{params[:limit]}&offset=#{params[:offset]}",{}, headers)
    returned = {
        results: [],
        pagination: {
            more: true
        }
    }
    returned[:pagination][:more] = false if phones.length < params[:limit].to_i
    phones.each do |phone|
      client = JSON.parse phone.to_json
      client["phone"] =  client["cellPhone"] if client["phone"].to_s.match(params[:search]) && client["cellPhone"].to_s.match(params[:search])
      client["phone"] =  client["secondaryPhone"] if client["phone"].to_s.match(params[:search]) && client["secondaryPhone"].to_s.match(params[:search])
      text = ""
      if client["phone"].present? && client["phone"].length >= 10
        text = client["phone"][0,3].to_s + "-" + client["phone"][3,3].to_s+ "-" + client["phone"][6,10].to_s +
                  " " + client["firstName"].to_s + " " + client["lastName"].to_s
      elsif client["phone"].present?
        text = client["phone"]+ " " + client["firstName"].to_s + " " + client["lastName"].to_s  
      end
      returned[:results].push({
                                 id: phone["idClient"],
                                 text: text
                             })
      if client["business"]
        client["business"]["contacts"].each do |contact|
          returned[:results].push({
                                      id: phone["idClient"],
                                      text: text
                                  })
        end
      end
    end
    respond_json(returned)
  end

  def create
    quickquote = create_default_quote
    redirect_to edit_quote_path(id: quickquote.id)
  end

  def create_car
    @car = QuoteCar.new(
        idQuote: params[:quote],
        idCar: params[:veh],
        missingWheels: 0,
        missingBattery: nil,
        missingCat: nil,
        gettingMethod: "pickup",
        )
    @car.save!
    respond_json(@car)
  end

	def edit_quotes
    @quote = Quote.includes(:dispatcher,customer: [:address,:heardofus]).where(idQuote: params[:id]).first
    cars =  QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuote: params[:id])
    @heardsofus = Heardofus.all
    render  locals: {
                       user: current_user,
                       quote: @quote,
                       cars: cars,
                       heardsofus: @heardsofus
                     }
  end

  def render_vehicle
    vehicle = VehicleInfo.where(idVehiculeInfo: params[:vehicle]).first
    car = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuoteCars: params[:car]).first
    render partial: 'quote/vehicle_parameters', locals: {
        car: car,
        vehicle: vehicle,
    }
  end

  def remove_car
    @quote_car = QuoteCar.where(idQuoteCars: params[:car])
    @quote_car.destroy_all
    return render_json_response({:msg => "ok"}, :ok)
  end


  def status_json
    res = ApiCall.get("/status", {}, headers)
    respond_json(res)
  end

  def update_quote_status
    if (params[:status])
      quotes = Quote.includes(:customer).where(idQuote: params[:no]).first
      if quotes.present?
        quotes.idStatus = params[:status]
        quotes.dtStatusUpdated = Time.now
        quotes.save!
      end
      if (params[:status] == 6)
        # Check if sms already sent.
        if (!quotes.isSatisfactionSMSQuoteSent && quotes.customer.cellPhone)
          sms = TwilioTextMessenger.new "Hello. This is CashForTrash. We recently bought your car. We want to know your satisfaction. On a scale of 1 to 10, how much did you appreciate our service? Please respond with a number.", "4388241370"
          sms.call
          quotes.update(isSatisfactionSMSQuoteSent: 1)
        end
      end
    end
    respond_json(quotes)
  end
 end
