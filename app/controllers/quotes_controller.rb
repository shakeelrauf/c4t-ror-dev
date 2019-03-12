class QuotesController < ApplicationController
  before_action :login_required
  include Quotesmethods

  def index
    @quotes = Quote.includes(:customer, :dispatcher,:status).all.order('dtCreated desc')
    @pages = 0
    if @quotes.count % 15 > 0
      @pages = 1
    end
    @pages += (@quotes.count / 15).ceil
    @quotes = @quotes.limit(15).offset(0)
    @status = Status.all
    render :index
  end

  def index2
    respond_to do |format|
      format.html
      format.json { render json: QuotesDatatable.new(view_context) }
    end
  end

  def car_price
    return respond_json({"netPrice": nil}) if (params[:byWeight] == "1" ? false : (!params[:missingWheels].present? || !params[:missingBattery].present? || !params[:missingCat].present?))
    @quote = Quote.where(idQuote: params[:quoteId]).first
    quote = JSON.parse @quote.to_json
    customer = Customer.find_by_id(params[:customer_id])
    return respond_json({"netPrice": nil}) if quote.nil?
    car =  QuoteCar.where(idQuoteCars: params[:car]).first
    r = intialize_calculations_and_make_response(car, params, quote)
    if customer.present? && customer.type != "Individual" && params[:byWeight] != "1"
      bonus = calculate_bonus_or_flatfee(customer, r)
      bonus,r = response_according_bonus(bonus, r)
    end
    r = save_car_return_response(car,r, params) if car.present? 
    r = check_increase_in_new_price(bonus, r,params, car)
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
    car_list = []
    begin
      car_list = JSON.parse(params[:cars].to_json)
    rescue
      return respond_json({:error => "The cars cannot be parsed"})
    end
    phone_type = " "
    phone_type_1 = " "
    phone_type_2 = " "
    if params[:phoneType] == "primary" || params[:phoneType] == ""
      phone_type = phone
      phone_type_1 = " "
      phone_type_2 = " "
    elsif params[:phoneType] == "cell"
      phone_type = " "
      phone_type_1 = phone
      phone_type_2 = " "
    elsif params[:phoneType] == "other"
      phone_type = " "
      phone_type_1 = " "
      phone_type_2 = phone
    end
    heard_of_us = Heardofus.find_or_initialize_by(type: params[:heardofus])
    heard_of_us.save! if heard_of_us.new_record?
    if !car_list.nil?
      client = save_customer params, heard_of_us,phone, phone_type, phone_type_1, phone_type_2, params[:customerType]
      Quote.custom_upsert({note: params[:note],idUser: current_user.present? ? current_user.idUser : nil ,idClient: client.idClient},{idQuote: params[:quote]})
      hash = {}
      car_list.each do |car, val|
        quote_car = QuoteCar.where(idQuoteCars: car_list[car]["car"]).first
        if car_list[car]["carAddressId"].present?
          address = Address.find_by_id(car_list[car]["carAddressId"])
          if address.present?
            address.postal = car_list[car]["carPostal"] if car_list[car]["carPostal"].present?
            address.address = car_list[car]["carStreet"] if car_list[car]["carStreet"].present?
            address.province = car_list[car]["carProvince"] if car_list[car]["carProvince"].present?
            address.city = car_list[car]["carCity"] if car_list[car]["carCity"].present?
            address.save
          end
          quote_car.update(idAddress: address.idAddress) if address.present?
          hash["#{car_list[car]["car"]}"] =  address.idAddress
        else
          update_quote_car_address car_list[car], quote_car, client, hash if car_list[car]["carPostal"].present?
        end
        quote_car.update(missingBattery: car_list[car]["missingBattery"],missingCat: car_list[car]["missingCat"],gettingMethod: car_list[car]["gettingMethod"],missingWheels: car_list[car]["missingWheels"], still_driving: car_list[car]["still_driving"] ) if quote_car.present?
      end

      return respond_json({message: "QuickQuote saved", customer_id: client.idClient, carlist: hash})
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
    if params[:search].present?
      phones = Customer.where('phone LIKE ? OR cellPhone LIKE ? OR secondaryPhone LIKE ?', params[:search] + "%",params[:search] + "%", params[:search] + "%").limit(params[:limit].to_i).offset(params[:offset].to_i * params[:limit].to_i)
      returned = {results: [], pagination: {more: true}}
      returned[:pagination][:more] = false if phones.length < params[:limit].to_i
      phones.each do |phone|
        client = JSON.parse phone.to_json
        client["phone"] =  client["cellPhone"] if  client["cellPhone"].to_s.match(params[:search])
        client["phone"] =  client["secondaryPhone"] if  client["secondaryPhone"].to_s.match(params[:search])
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
    else
      returned = {results: [], pagination: {more: true}}
      returned[:pagination][:more] = false
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
    if customer.business && customer.business.usersFlatFee == true
      custom_fee = Setting.where(name: "DealerFlatFee").first.value
      price = price_according_to_grade(customer, net_price)
      hash = {user_flat_fee: true,bonus: price, flat_fee: custom_fee.to_f }
    else
      price = price_according_to_grade(customer, net_price)
      hash = {user_flat_fee: false,bonus: price }
    end
  end

  def bonus_price(setting,value,net_price)
    if setting.first.value == "flatfee"
      hash = {type: "flatfee", value: '%.2f' % value.first.value.to_f }
    elsif setting.first.value == "card"
      hash = {type: "carprice", value: '%.2f' % value.first.value.to_f }
    elsif setting.first.value == "carp"
      percentage = '%.2f' % ((net_price[:steelPrice].to_f * net_price[:weight] * value.first.value.to_f)/100)
      hash = {type: "carprice", value: percentage }
    elsif setting.first.value == "steelp"
      percentage = '%.2f' % ((net_price[:steelPrice].to_f * value.first.value.to_f)/100)
      hash = {type: "steelprice", value: percentage }
    elsif setting.first.value == "steeld"
      hash = {type: "steelprice", value: '%.2f' % value.first.value.to_f }
    end
    return hash
  end

  def response_according_bonus(bonus, r)
    if bonus.is_a? Hash
      if bonus[:user_flat_fee] == true
        r[:netPrice] = bonus[:flat_fee].to_f
        r[:weightPrice] = " "
        r[:distanceCost] = " "
        r[:doorPrice] = '%.2f' % bonus[:flat_fee].to_f
        if bonus[:bonus].present?
          if bonus[:bonus][:type] == "carprice"
            r[:carPrice] = '%.2f' % (netPrice.to_f + bonus[:bonus][:value].to_f )
            r[:dropoffPrice] = r[:pickupPrice] = r[:netPrice] = '%.2f' % (r[:netPrice].to_f + bonus[:bonus][:value].to_f)
          elsif bonus[:bonus][:type] == "steelprice"
            r[:steelPrice] = '%.2f' % ( r[:steelPrice].to_f + bonus[:bonus][:value].to_f)
            r[:dropoffPrice] = r[:pickupPrice] = r[:netPrice] =  '%.2f' %  (r[:netPrice].to_f + bonus[:bonus][:value].to_f)
          elsif bonus[:bonus][:type] == "flatfee"
            r[:carPrice] = r[:dropoffPrice] = r[:pickupPrice] = r[:netPrice] = '%.2f' % ( r[:weight] * (r[:netPrice] + bonus[:bonus][:value].to_f))
          else
            r[:carPrice] = r[:dropoffPrice] = r[:pickupPrice] = r[:netPrice] = '%.2f' %  (r[:weight] * (r[:netPrice] + bonus[:bonus][:value].to_f))
          end
        end
      elsif bonus[:user_flat_fee] == false
        if bonus[:bonus].present?
          if bonus[:bonus][:type] == "carprice"
            r[:carPrice] = '%.2f' % (netPrice.to_f + bonus[:bonus][:value].to_f )
            if isPickup
              r[:pickupPrice] = r[:netPrice] = '%.2f' % ( r[:netPrice].to_f + bonus[:bonus][:value].to_f)
              r[:dropoffPrice] += bonus[:bonus][:value].to_f
            else
              (r[:dropoffPrice] = r[:netPrice] =  r[:netPrice].to_f + bonus[:bonus][:value].to_f)
              r[:pickupPrice] += bonus[:bonus][:value].to_f
            end
          elsif bonus[:bonus][:type] == "steelprice"
            r[:steelPrice] = '%.2f' % (r[:steelPrice].to_f + bonus[:bonus][:value].to_f)
            r[:netPrice] = '%.2f' % (r[:netPrice].to_f + bonus[:bonus][:value].to_f)
            if isPickup
              r[:pickupPrice] = r[:netPrice] = '%.2f' % (r[:netPrice].to_f + bonus[:bonus][:value].to_f)
              r[:dropoffPrice] += bonus[:bonus][:value].to_f
            else
              (r[:dropoffPrice] = r[:netPrice] = '%.2f' % (r[:netPrice].to_f + bonus[:bonus][:value].to_f))
              r[:pickupPrice] += bonus[:bonus][:value].to_f
            end
            # elsif bonus[:bonus][:type] == "flatfee"
          #   r[:netPrice] =  r[:netPrice].to_f + bonus[:bonus][:value].to_f
          end
        end
      end
      return [bonus, r]
    end
  end

  def save_car_return_response(car,r, params)
    car.missingWheels = params[:missingWheels]
    car.missingBattery = params[:missingBattery]
    if params[:new_price].present?
      r[:car_new_price] = '%.2f' % ( params[:new_price].to_f)
    else
      r[:car_new_price] = car.new_price
    end
    r[:car_new_price] = r[:netPrice].to_f+0.1 if r[:netPrice].to_f >= r[:car_new_price].to_f
    car.new_price =  r[:car_new_price]
    car.missingCat = params[:missingCat]
    car.still_driving = params[:still_driving]
    car.gettingMethod =  params[:gettingMethod]
    car.weight = (params[:weight].to_f ) if  params[:weight].present?
    car.by_weight = params[:byWeight]  if params[:byWeight].present?
    car.save!
    return r
  end

  def intialize_calculations_and_make_response(car, params, quote)
    car_distance =  params[:distance]
    car_distance = car_distance.to_i if car_distance.present?
    excessDistance = 0.0
    excessDistance = [car_distance- quote["freeDistance"].to_i, 0.0 ].max if car_distance.present? && car_distance != "NOT_FOUND" && car_distance != "ZERO_RESULTS"
    pickupCost    = quote["pickup"].to_f
    isPickup      = (params[:gettingMethod] == "pickup")
    excessCost    = isPickup ? quote["excessCost"].to_f : 0.0
    distanceCost  = excessDistance * excessCost
    weightPrice   = params[:weight].to_f / 1000.0 * quote["steelPrice"].to_f
    weightPrice   = params[:weight].to_f / 1000.0 * quote["steelPrice"].to_f if params[:byWeight] == "1"
    dropoff = weightPrice
    dropoff -=  params[:missingWheels].to_i * quote["steelPrice"].to_f
    dropoff -=  params[:missingCat].to_i * quote["catPrice"].to_f
    dropoff -=  params[:missingBattery].to_i * quote["batteryPrice"].to_f
    dropoffPrice = [dropoff,0.0].max
    pickupPrice = 0.0
    if car_distance.present? && car_distance >  0.01 && excessDistance.present?
      pickupPrice = [(dropoffPrice - (excessDistance * quote["excessCost"].to_f) - pickupCost), 0.0].max
    end
    netPrice = (params[:byWeight] == "1" ? weightPrice : isPickup ? pickupPrice : dropoffPrice)
    r = {netPrice: netPrice,
         pickupPrice: pickupPrice,
         dropoffPrice: dropoffPrice
    }
    r[:weight] =  params[:weight].to_f / 1000.0
    r[:steelPrice] =  quote["steelPrice"].to_f
    r[:weightPrice] = '%.2f' % weightPrice.to_f
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
    return r
  end

  def check_increase_in_new_price(bonus, r,params, car)
    r[:increase_in_price] = ('%.2f' %  (((r[:car_new_price].to_f - r[:netPrice].to_f)/r[:netPrice].to_f) * 100)).to_s + '%'
    r[:increase_approved] = false
    r[:increase_approved] = true if r[:increase_in_price].to_f > Setting.max_increase_with_admin_approval.to_f
    r[:weight] = params[:weight].to_f/1000.0 if params[:byWeight] == "1" && car.weight.present?
    r[:bonus] = bonus
    return r
  end

  def price_according_to_grade(customer, net_price)
    price = {type: "no", value: 0}
    if customer.grade == "Custom"
      price = {type: "custom", value: customer.customDollarCar}
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