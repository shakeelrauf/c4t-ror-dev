class QuotesController < ApplicationController
  before_action :login_required
  include Quotesmethods

  def index
    @quotes = Quote.includes(:customer, :dispatcher,:status).all
    @pages = 0
    if @quotes.count % 15 > 0
      @pages = 1
    end
    @pages += (@quotes.count / 15).ceil
    @quotes = @quotes.limit(15).offset(0)
    @status = Status.all
    render :index
  end

  def car_price
    return respond_json({"netPrice": nil}) if params[:missingWheel] == "" || params[:missingBattery] == "" || params[:missingCat] == ""
    quote = JSON.parse Quote.where(idQuote: params[:quoteId]).first.to_json
    return respond_json({"netPrice": nil}) if quote.nil?
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

  def search
    quotes, all_count = search_quotes params[:limit], params[:offset], params[:filter], params[:afterDate], params[:beforeDate]
    render json: { quotes: JSON.parse(quotes), count: all_count}
  end

  def initialize_quote
    quickquote = create_default_quote
    redirect_to edit_quote_path(id: quickquote.id)
  end

  def create
    save_quotes
  end

  def vehicle_search
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

  def phone_numbers
    phones = Customer.where('phone LIKE ? OR cellPhone LIKE ? OR secondaryPhone LIKE ?', params[:search] + "%", params[:search] + "%", params[:search] + "%").limit(params[:limit].to_i).offset(params[:offset].to_i * params[:limit].to_i)
    returned = {results: [], pagination: {more: true}}
    returned[:pagination][:more] = false if phones.length < params[:limit].to_i
    phones.each do |phone|
      client = JSON.parse phone.to_json
      client["phone"] =  client["cellPhone"] if client["phone"].to_s.match(params[:search]) && client["cellPhone"].to_s.match(params[:search])
      client["phone"] =  client["secondaryPhone"] if client["phone"].to_s.match(params[:search]) && client["secondaryPhone"].to_s.match(params[:search])
      text = ""
      if client["phone"].present? && client["phone"].length >= 10
        text = client["phone"][0,3].to_s + "-" + client["phone"][3,3].to_s+ "-" + client["phone"][6,10].to_s + " " + client["firstName"].to_s + " " + client["lastName"].to_s
      elsif client["phone"].present?
        text = client["phone"]+ " " + client["firstName"].to_s + " " + client["lastName"].to_s
      end
      returned[:results].push({id: phone["idClient"], text: text})
      if client["business"]
        client["business"]["contacts"].each do |contact|
          returned[:results].push({id: phone["idClient"],text: text})
        end
      end
    end
    respond_json(returned)
  end

  def update_status
    if (!params[:status] && !params[:id])
      return respond_json({"msg": "Failure!!", "success": false,:error => "please send attribute status."})
    else
      @quote = Quote.includes(:status).where(idQuote: params[:id])
      if !@quote.present?
        return respond_json({"msg": "Failure!!", "success": false,:error => "Quote not found"})
      else
        stats = Status.where(idStatus: params[:status])
        if params[:status] && stats.present?
          @quote.first.idStatus = params[:status]
          @quote.first.dtStatusUpdated = Time.now
          @quote.first.save(:validate => false)
          result = @quote
        else
          return respond_json({"msg": "Failure!!", "success": false,:error => "Status not found"})
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
        return respond_json(quotez)
      end
    end
  end


  def create_car
    car = QuoteCar.new(idQuote: params[:quote], idCar: params[:veh], missingWheels: 0, missingBattery: nil, missingCat: nil, gettingMethod: "pickup")
    car.save!
    respond_json(car)
  end

  def edit
    @quote = Quote.includes(customer: [:address]).where(idQuote: params[:id]).first
    cars =  QuoteCar.includes([:information, :address]).where(idQuote: params[:id])
    @heardsofus = Heardofus.all
    render :edit, locals: {user: current_user, quote: @quote, cars: cars, heardsofus: @heardsofus}
  end

  def remove_car
    @quote_car = QuoteCar.where(idQuoteCars: params[:car])
    @quote_car.destroy_all
    return respond_json({:msg => "ok"})
  end

  def status
    status = Status.all
    respond_json(status)
  end

  def update_quote_status
    if (params[:status])
      quotes = Quote.includes(:customer).where(idQuote: params[:no]).first
      if quotes.present?
        quotes.idStatus = params[:status]
        quotes.dtStatusUpdated = Time.now
        quotes.save!
        if (params[:status] == 6)
          if (!quotes.isSatisfactionSMSQuoteSent && quotes.customer.cellPhone)
            sms = TwilioTextMessenger.new "Hello. This is CashForTrash. We recently bought your car. We want to know your satisfaction. On a scale of 1 to 10, how much did you appreciate our service? Please respond with a number.", "4388241370"
            sms.call
            quotes.update(isSatisfactionSMSQuoteSent: 1)
          end
        end
      end
    end
    respond_json(quotes)
  end
end