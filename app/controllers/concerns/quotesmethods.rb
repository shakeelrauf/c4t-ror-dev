module Quotesmethods
  include Distancemethods
  def quote_car_params
    {quote: params[:quote],veh: params[:veh]}
  end

  def create_default_quote
    settings = Setting.run_sql_query("SELECT * FROM settings WHERE dtCreated IN (SELECT MAX(dtCreated) FROM settings GROUP BY name)")
    settings_hash = {}
    settings.each do |setting|
      settings_hash[setting["name"]] = setting["value"]
    end
    count = Quote.where(dtCreated: DateTime.now.strftime("%Y-%m-01 00:00:00")).count
    reference = DateTime.now.strftime("%Y%m") +("0000"+( count+1).to_s).last(4)
    quote = Quote.new(
        idUser:  current_user.idUser,
        referNo: reference,
        smallCarPrice: settings_hash["smallCarPrice"] || "0",
        midCarPrice: settings_hash["midCarPrice"] || "0",
        largeCarPrice: settings_hash["largeCarPrice"] || "0",
        steelPrice: settings_hash["steelPrice"] || "0",
        wheelPrice: settings_hash["wheelPrice"] || "0",
        catPrice: settings_hash["catalysorPrice"] || "0",
        batteryPrice: settings_hash["batteryPrice"] || "0",
        excessCost: settings_hash["excessPrice"] || "0",
        freeDistance: settings_hash["freeDistance"] || "0",
        pickup: settings_hash["pickup"] || "0",
        dtCreated: DateTime.now,
        dtStatusUpdated: DateTime.now
    )
    quote.save!
    quote
  end

  def vehicles_search(limit=100, offset=0, q)
    # limit = 30
    # offset = 0
    # limit = (limit_p.present? ? limit_p.to_i : 30)
    # offset = offset_p.present? ? offset_p.to_i : 0
    if q.present?
      # filter = + q.gsub(/[\s]/, "% %") + "%"
      filters = q.split(' ')
      # query = "Select * from vehicle_infos where"
      strings = []
      query = "idVehiculeInfo is not null"
      filters.each do |fil|
        # query.concat(" year LIKE '#{fil}' OR make LIKE '#{fil}' OR model LIKE '#{fil}' OR trim LIKE '#{fil}' OR body LIKE '#{fil}' OR drive LIKE '#{fil}' OR transmission LIKE '#{fil}' OR seats LIKE '#{fil}' OR doors LIKE '#{fil}' OR weight LIKE '#{fil}'")
        # query.concat(" AND ") if !fil.eql?(filters.last)
        query += " and searchable like ?"
        strings << "%#{fil}%"
      end
      w = [query] + strings
      r_vehicles = VehicleInfo.where(w)
    end
    r_vehicles = JSON.parse(VehicleInfo.all.limit(limit).offset(offset).to_json) if !q.present?
    return r_vehicles
  end

  def save_quotes
    return respond_json({:error => "First Name is missing in customer attributes."}) if (!params[:firstName].present?)
    return respond_json({:error => "Last Name is missing in customer attributes."}) if (!params[:lastName].present?)
    # return respond_json({:error => "Postal Code is missing in customer attributes."}) if (!params[:postal].present?)
    return respond_json({:error => "Heard of us is missing in customer attributes."}) if (!params[:heardofus].present?)
    return respond_json({:error => "Phone Type is missing in customer attributes."}) if (params[:phoneType] == "Select an option")
    return respond_json({:error => "Customer Type is missing in customer attributes."}) if (!params[:customerType].present? )
    # postal_code = Validations.postal(params[:postal])
    # return respond_json({:error => "The postal code seems invalid."}) if (postal_code.length != 7)
    phone = params[:phone].present? ? params[:phone].gsub("-","") : ""
    return respond_json({:error => "phone number length must be at least 10 digits."}) if (phone.to_s.length < 10)
    carList = []
    begin
      carList = JSON.parse(params[:cars].to_json)
    rescue
      return respond_json({:error => "The cars cannot be parsed"})
    end
    if params[:phoneType] == "home" || params[:phoneType] == ""
      phoneType = phone
      phoneType_1 = " "
      phoneType_2 = " "
    elsif params[:phoneType] == "cell"
      phoneType = " "
      phoneType_1 = phone
      phoneType_2 = " "
    elsif params[:phoneType] == "work"
      phoneType = " "
      phoneType_1 = " "
      phoneType_2 = phone
    end
    customerType = params[:customerType]
    heard_of_us = Heardofus.find_or_initialize_by(type: params[:heardofus])
    heard_of_us.save! if heard_of_us.new_record?
    if !carList.nil?
      carList.each do |car, val|
        return respond_json({:error => "The type of vehicle was not selected"}) if (!carList[car]["car"].present?)
        return respond_json({:error => "The missing wheels was not selected" , car:  carList[car]["car"]}) if carList[car]["byWeight"] == "1" ? false  :  (!carList[car]["missingWheels"].present?)
        return respond_json({:error => "The still driving was not selected" , car:  carList[car]["car"]}) if (!carList[car]["still_driving"].present?)
        return respond_json({:error => "The catalytic converter missing was not selected" , car:  carList[car]["car"]}) if carList[car]["byWeight"] == "1" ? false  : (!carList[car]["missingCat"].present?)
        return respond_json({:error => "The missing battery was not selected ", car:  carList[car]["car"]}) if carList[car]["byWeight"] == "1" ? false : (!carList[car]["missingBattery"].present?)
        return respond_json({:error => "The address was not selected properly with postal code ", car:  carList[car]["car"]}) if (carList[car]["carAddressId"] == "" && carList[car]["carPostal"] == "")
      end
      client = save_customer params, heard_of_us, phone,phoneType, phoneType_1, phoneType_2, customerType
      hash = {}
      carList.each do |car, val|
        quote_car = QuoteCar.where(idQuoteCars: carList[car]["car"]).first
        if carList[car]["carAddressId"].present?
          address = Address.find_by_id(carList[car]["carAddressId"])
          if address.present?
            car_postal_code = Validations.postal(carList[car]["carPostal"])
            return respond_json({:error => "Invalid Car Postal Code", car:  carList[car]["car"]}) if  (car_postal_code.length != 7)
            address.postal = carList[car]["carPostal"] if carList[car]["carPostal"].present?
            address.province = carList[car]["carProvince"] if carList[car]["carProvince"].present?
            address.city = carList[car]["carCity"] if carList[car]["carCity"].present?
            address.address = carList[car]["carStreet"] if carList[car]["carStreet"].present?
            address.save
          end
          address.update(idClient: client.idClient) if params[:new_customer] == "true"
          quote_car.update(idAddress: address.idAddress) if address.present?
          hash["#{carList[car]["car"]}"] =  address.idAddress
        else
          car_postal_code = Validations.postal(carList[car]["carPostal"])
          return respond_json({:error => "Invalid Car Postal Code", car:  carList[car]["car"]}) if  (car_postal_code.length != 7)
          return respond_json({:error => "Missing Car city", car:  carList[car]["car"]}) if  (car_postal_code.present? && !carList[car]["carCity"].present?)
          return respond_json({:error => "Missing Car Street", car:  carList[car]["car"]}) if  ( car_postal_code.present? && !carList[car]["carStreet"].present?)
          return respond_json({:error => "Missing Car Province", car:  carList[car]["car"]}) if  (car_postal_code.present? && !carList[car]["carProvince"].present?)
          update_quote_car_address carList[car], quote_car, client, hash if carList[car]["carPostal"].present?
        end
        quote_car.update(missingBattery: carList[car]["missingBattery"],missingCat: carList[car]["missingCat"],gettingMethod: carList[car]["gettingMethod"],missingWheels: carList[car]["missingWheels"], still_driving: carList[car]["still_driving"] ) if quote_car.present?
      end
      q = Quote.custom_upsert({note: params[:note],idUser: current_user.present? ? current_user.idUser : nil ,idClient: client.idClient, is_published: true},{idQuote: params[:quote]})
      return respond_json({message: "QuickQuote saved" , q: q})
    else
       return respond_json({error: "Please select at least one car"})
    end
  end

  def search_quotes limit_p, offset_p, filter,after_date, before_date,order=nil, order_by=nil
    limit = 15
    offset = 0
    all_count = 0
    limit  = limit_p.delete(' ') if limit_p.to_i > 0
    offset = ((offset_p.to_i) * limit.to_i) if offset_p != "-1"
    query =  ""
    if filter
      filter = "%" + filter.gsub(/[\s]/, "% %").gsub('?','') + "%"
      filters =  filter.split(' ')
      length =  filters.length
      filters.each.with_index do |fil,i|
        query+= "('note' like '#{fil}' OR referNo like '#{fil}' OR clients.firstName like '#{fil}' OR clients.lastName like '#{fil}' OR clients.phone like '#{fil}' OR clients.cellPhone like '#{fil}' OR clients.secondaryPhone like '#{fil}' OR users.firstName like '#{fil}' OR users.lastName like '#{fil}' OR status.name like '#{fil}')"
        query+= " AND " if i < (length -1)
      end
      # query = "(#{query}) AND (('dtCreated' <= '#{after_date+ ' 00:00:00'}') AND ('dtCreated' >= '#{before_date+ ' 23:59:59'}'))" if after_date && after_date.to_s.length == 10 && DateTime.parse(after_date, "YYYY-MM-DD")
      quotes =  Quote.eager_load(:status, :customer, :dispatcher).where(query).order("#{order_by} #{order} ")
      if quotes.count % 15 > 0
        all_count = 1
      end
      all_count += (quotes.count / limit.to_i).ceil
      quotes = quotes.limit(limit).offset(offset).to_json(include: [:dispatcher, :customer, :status])
    else
      quotes =  Quote.includes(:dispatcher, :customer, :status)
      if quotes.count % 15 > 0
        all_count = 1
      end
      all_count += (quotes.count / limit.to_i).ceil
      quotes = quotes.limit(limit).offset(offset).to_json(include: [:dispatcher, :customer, :status])
    end
    return quotes, all_count
  end

  def update_quote_car_address car, quote_car, client, hash
    ad = Address.where(postal: car["carPostal"],city: car["carCity"], province: car["carProvince"], address: car["carStreet"], idClient: client.idClient).first
    ad = Address.new if ad.nil?
    res = car["distance"]
    ad.postal = car["carPostal"]
    ad.city = car["carCity"]
    ad.idClient = client.idClient  if client.present?
    ad.province = car["carProvince"]
    ad.address = car["carStreet"]
    ad.distance = res
    ad.save!
    # @add = Address.where(idAddress: quote_car.idAddress).first if quote_car && quote_car.idAddress.present?
    quote_car.idAddress = ad.idAddress
    quote_car.save! #if quote_car && quote_car.idAddress.present?
    hash["#{car["car"]}"] =  ad.idAddress

    # @add.destroy if quote_car && quote_car.idAddress.present? && @add.idAddress != quote_car.idAddress
  end

  def save_customer params, heard_of_us,phone, phoneType, phoneType1, phoneType2, customerType
    if (params[:new_customer] == "true" && params[:new_customer_id] != "false")
      client = Customer.where(idClient: params[:new_customer_id]).first
      client.idHeardOfUs = heard_of_us.idHeardOfUs
      client.phone = phoneType if phoneType.present?
      client.cellPhone = phoneType1 if phoneType1.present?
      client.secondaryPhone = phoneType2 if phoneType2.present?
      client.firstName = params[:firstName]
      client.lastName = params[:lastName]
      client.type = customerType
      client.phone_type = params[:phoneType]
      client.save!
    else
      customer = phone_settings(params, heard_of_us,phone, phoneType, phoneType1, phoneType2, customerType)
      client = Customer.custom_upsert(customer,{phone: phone})
    end
    client.extension = params[:extension]
    client.save!
    # address = client.address.first
    # postal_code = Validations.postal(params[:postal])
    # address =  client.address.build  if (params[:new_customer] == "true" && params[:new_customer_id] != "false") && address.nil?
    # if (!address.nil? && postal_code.length == 7)
    #   address.postal = postal_code
    #   address.city =  " " if address.new_record?
    #   address.address = " " if address.new_record?
    #   address.province = " " if address.new_record?
    #   address.distance = " " if address.new_record?
    #   address.save!
    # end
    client
  end

  def phone_settings(params, heard_of_us,phone, phoneType, phoneType1, phoneType2, customerType)
    val = {idHeardOfUs: heard_of_us.idHeardOfUs, firstName: params[:firstName],lastName: params[:lastName], type: customerType, phone_type: params[:phoneType]}
    val = val.merge({phone: phoneType}) if phoneType.present?
    val = val.merge({cellPhone: phoneType1}) if phoneType1.present?
    val = val.merge({secondaryPhone: phoneType2}) if phoneType2.present?
    val
  end
end
