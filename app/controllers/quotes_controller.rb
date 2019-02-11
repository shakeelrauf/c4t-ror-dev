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
    return respond_json({"netPrice": nil}) if !params[:missingWheels].present? || !params[:missingBattery].present? || !params[:missingCat].present?
    @quote = Quote.where(idQuote: params[:quoteId]).first
    quote = JSON.parse @quote.to_json
    customer = Customer.find_by_id(params[:customer_id])
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
    car =  QuoteCar.where(idQuoteCars: params[:car]).first
    car.update(missingWheels: params[:missingWheels], missingBattery: params[:missingBattery], missingCat: params[:missingCat],still_driving: params[:still_driving], gettingMethod: params[:gettingMethod]) if car.present?
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
    r[:carPrice] = '%.2f' % netPrice.to_f
    if customer.present? && customer.type == "Dealership"
      bonus = calculate_bonus_or_flatfee(customer, r)
      if bonus.is_a? Array
        if bonus[0] == "flatfee"
          r = {netPrice: bonus[1].to_f,
               pickupPrice: pickupPrice
          }
          r[:weight] =  params[:weight].to_f / 1000.0
          r[:steelPrice] =  quote["steelPrice"].to_f
          r[:weightPrice] = " "
          r[:distance] = car_distance.to_f
          r[:freeDistance] = quote["freeDistance"].to_f
          r[:excessDistance] = excessDistance.to_f
          r[:excessCost] =  excessCost.to_f
          r[:distanceCost] = " "
          r[:missingCatCost] = quote["catPrice"].to_f
          r[:missingBatCost] = quote["batteryPrice"].to_f
          r[:missingCat] = -(quote["catPrice"].to_f * params[:missingCat].to_f)
          r[:missingBat] = -(quote["batteryPrice"].to_f * params[:missingBattery].to_f)
          r[:missingWheelsCost] = quote["wheelPrice"].to_f
          r[:missingWheels] = -(quote["wheelPrice"].to_f * params[:missingWheels].to_f)
          r[:pickupCost] = quote["pickup"].to_f
          r[:carPrice] = '%.2f' % bonus[1].to_f
        elsif bonus[0] == "carprice"
          r[:carPrice] = '%.2f' % (netPrice.to_f + bonus[1].to_f )
          r[:netPrice] =  r[:netPrice].to_f + bonus[1].to_f
        # elsif bonus[0] == "custom"
        #   r[:carPrice] = '%.2f' % (netPrice.to_f + bonus[1].to_f )
        #   r[:netPrice] =  r[:netPrice].to_f + bonus[1].to_f
        elsif bonus[0] == "steelprice"
          r[:steelPrice] = r[:steelPrice].to_f + bonus[1].to_f
          r[:netPrice] =  r[:netPrice].to_f + bonus[1].to_f
        end
      end
    end
    r[:bonus] = bonus
    respond_json(r)
  end

  def search
    quotes, all_count = search_quotes params[:limit], params[:offset], params[:filter], params[:afterDate], params[:beforeDate]
    render json: { quotes: JSON.parse(quotes), count: all_count}
  end

  def initialize_quote
    quickquote = create_default_quote
    if params[:no].present?
      redirect_to edit_quote_path(id: quickquote.id, customer_id: params[:no])
    else
      redirect_to edit_quote_path(id: quickquote.id)
    end
  end

  def create
    save_quotes
  end

  def quotes_save_without_validations
    phone = params[:phone].present? ? params[:phone].gsub("-","") : ""
    return respond_json({:error => "phone number length must be at least 10 digits."}) if (phone.to_s.length < 10)
    carList = []
    begin
      carList = JSON.parse(params[:cars].to_json)
    rescue
      return respond_json({:error => "The cars cannot be parsed"})
    end
    phoneType1 = " "
    phoneType2 = " "
    heard_of_us = Heardofus.find_or_initialize_by(type: params[:heardofus])
    heard_of_us.save! if heard_of_us.new_record?
    if !carList.nil?
      client = save_customer params, heard_of_us, phone, phoneType1, phoneType2, params[:customerType]
      Quote.custom_upsert({note: params[:note],idUser: current_user.present? ? current_user.idUser : nil ,idClient: client.idClient},{idQuote: params[:quote]})
      carList.each do |car, val|
        quote_car = QuoteCar.where(idQuoteCars: carList[car]["car"]).first
        if carList[car]["carAddressId"].present?
          address = Address.find_by_id(carList[car]["carAddressId"])
          quote_car.update(idAddress: address.idAddress) if address.present?
        else
          car_postal_code = Validations.postal(carList[car]["carPostal"])
          update_quote_car_address carList[car], quote_car, client if carList[car]["carPostal"].present?
        end
        quote_car.update(missingBattery: carList[car]["missingBattery"],missingCat: carList[car]["missingCat"],gettingMethod: carList[car]["gettingMethod"],missingWheels: carList[car]["missingWheels"], still_driving: carList[car]["still_driving"] ) if quote_car.present?
      end
      return respond_json({message: "QuickQuote saved", customer_id: client.idClient})
    else
      return respond_json({error: "Please select atleast one car"})
    end
  end

  def vehicle_search
    limit =  15
    offset = 0
    limit = params[:limit] if params[:limit].present?
    offset = (params[:page].to_i - 1) * limit if params[:page].present?
    vehicles = vehicles_search(limit, offset, params[:q])
    groups = []
    vehicles.each do |vehicle|
      item = {}
      if vehicle["make"] == "Other"
        item["text"]= "Other"
      else
        item["text"] = vehicle["make"].to_s + " " + vehicle["year"].to_s + " " + vehicle["model"].to_s + " " + vehicle["body"].to_s + " " + vehicle["trim"].to_s + " " + vehicle["transmission"].to_s + " " + vehicle["drive"].to_s + " " + vehicle["doors"].to_s + " doors and " + vehicle["seats"].to_s + " seats."
        item["id"] = vehicle["idVehiculeInfo"]
        created = false
        groups.each do |i|
          if i[:text].to_s == vehicle["make"].to_s
            i[:children].push(item)
            created = true
            break
          end
        end
      end
      groups.push({text: vehicle["make"], children: [item]}) if !created
    end
    returned = {}
    returned[:results] = groups
    returned[:pagination] = {}
    if(vehicles.length < limit)
      returned[:pagination][:more] = false
    else
      returned[:pagination][:more] = true
    end
    respond_json(returned)
  end

  def phone_numbers
    phones = Customer.where('phone LIKE ?', params[:search] + "%").limit(params[:limit].to_i).offset(params[:offset].to_i * params[:limit].to_i)
    returned = {results: [], pagination: {more: true}}
    returned[:pagination][:more] = false if phones.length < params[:limit].to_i
    phones.each do |phone|
      client = JSON.parse phone.to_json
      # client["phone"] =  client["cellPhone"] if client["phone"].to_s.match(params[:search]) && client["cellPhone"].to_s.match(params[:search])
      # client["phone"] =  client["secondaryPhone"] if client["phone"].to_s.match(params[:search]) && client["secondaryPhone"].to_s.match(params[:search])
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
    return respond_json({"msg": "Failure!!", "success": false,:error => "please send attribute status."}) if (!params[:status] && !params[:id])
    @quote = Quote.includes(:status).where(idQuote: params[:id]).first
    return respond_json({"msg": "Failure!!", "success": false,:error => "Quote not found"}) if !@quote.present?
    stats = Status.where(idStatus: params[:status]).first
    return respond_json({"msg": "Failure!!", "success": false,:error => "Status not found"}) if !(params[:status] && stats.present?)
    @quote.idStatus = params[:status]
    @quote.dtStatusUpdated = Time.now
    @quote.save(:validate => false)
    result = @quote
    quotez = { "msg": "Success!!","success": true,"data": result}
    return respond_json(quotez)
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
    if params[:customer_id].present?
      @customer = Customer.where(idClient: params[:customer_id]).first
      @address = @customer.try(:address)
    end
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

  private
  def calculate_bonus_or_flatfee(customer, net_price)
    flat_fee = 0
    if customer.business.usersFlatFee == true
      custom_fee = Setting.where(name: "DealerFlatFee").first.value
      ["flatfee", custom_fee.to_s]
    else
      price = price_according_to_grade(customer, net_price)
      price
    end
  end

  def bonus_price(setting,value,net_price)
    if setting.first.value == "flatfee"
      price = ["flatfee", value.first.value]
    elsif setting.first.value == "card"
      price = ["carprice", value.first.value]
    elsif setting.first.value == "carp"
      percentage = (net_price[:carPrice].to_f * value.first.value.to_f)/100
      price = ["carprice", percentage]
    elsif setting.first.value == "steelp"
      percentage = (net_price[:steelPrice].to_f * value.first.value.to_f)/100
      price = ["steelprice", percentage]
    elsif setting.first.value == "steeld"
      price = ["steelprice", value.first.value]
    end
    return price
  end

  def price_according_to_grade(customer, net_price)
    price = ["no", 0]
    if customer.grade == "Custom"
      price =["custom", customer.customDollarCar]
    else
      if customer.grade == "Bronze"
        settings = Setting.where(grade: 'Bronze')
        value = settings.select{|s| s.label =="bonus"}
        setting = settings.select{|s| s.label =="bonus-type"}
        price = bonus_price(setting,value, net_price)
      elsif customer.grade == "Silver"
        settings = Setting.where(grade: 'Silver')
        value = settings.select{|s| s.label =="bonus-1"}
        setting = settings.select{|s| s.label =="bonus-type-1"}
        price = bonus_price(setting,value, net_price)
      elsif customer.grade == "Gold"
        settings = Setting.where(grade: 'Gold')
        value = settings.select{|s| s.label =="bonus-2"}
        setting = settings.select{|s| s.label =="bonus-type-2"}
        price = bonus_price(setting,value, net_price)
      end
    end
    return price
  end
end