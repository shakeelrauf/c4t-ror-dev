module Quotesmethods

  def quote_car_params
    {quote: params[:quote],veh: params[:veh]}
  end

  def create_default_quote
    settings = Setting.run_sql_query("SELECT * FROM Settings WHERE dtCreated IN (SELECT MAX(dtCreated) FROM Settings GROUP BY name)")
    settings_hash = {}
    settings.each do |setting|
      settings_hash[setting["name"]] = setting["value"]
    end
    count = Quote.where(dtCreated: DateTime.now.strftime("%Y-%m-01 00:00:00")).count
    reference = DateTime.now.strftime("%Y%m") +("0000"+( count+1).to_s).last(4)
    quote = Quote.create(
        idUser: current_user.idUser,
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
    quote
  end

  def vehicles_search(limit, offset, q)
    limit = 30
    offset = 0
    limit = (limit.present? ? limit.to_i : 30)
    offset = ((offset.to_i) * limit) if offset != "-1"
    if q.present?
      filter = + q.gsub(/[\s]/, "% %") + "%"
      filters = filter.split(' ')
      query = "Select * from VehiculesInfo where"
      filters.each do |fil|
        query.concat(" year LIKE '#{fil}' OR make LIKE '#{fil}' OR model LIKE '#{fil}' OR trim LIKE '#{fil}' OR body LIKE '#{fil}' OR drive LIKE '#{fil}' OR transmission LIKE '#{fil}' OR seats LIKE '#{fil}' OR doors LIKE '#{fil}' OR weight LIKE '#{fil}'")
        query.concat(" AND ") if !fil.eql?(filters.last)
      end
      r_vehicles = VehicleInfo.run_sql_query(query, offset, limit)
    end
    r_vehicles = JSON.parse(VehicleInfo.all.limit(limit).offset(offset).to_json) if !q.present?
    return r_vehicles
  end

  def save_quotes
    return respond_json({:error => "Please send all required customer attributes."}) if (!params[:firstName].present? || !params[:lastName].present? || !params[:postal].present? || !params[:heardofus].present? || !params[:phone].present?)
    postal_code = Validations.postal(params[:postal])
    return respond_json({:error => "The postal code seems invalid."}) if (postal_code.length != 7)
    phone = params[:phone].present? ? params[:phone].gsub("-","") : ""
    return respond_json({:error => "phone number length must be at least 10 digits."}) if (phone.to_s.length < 10)
    carList = []
    begin
      carList = JSON.parse(params[:cars].to_json)
    rescue
      return respond_json({:error => "The cars cannot be parsed"})
    end
    heard_of_us = Heardofus.find_or_initialize_by(type: params[:heardofus])
    heard_of_us.save! if heard_of_us.new_record?
    client = Customer.customUpsert({idHeardOfUs: heard_of_us.idHeardOfUs,phone: phone,firstName: params[:firstName],lastName: params[:lastName]},{phone: phone})
    quote = Quote.customUpsert({note: "",idUser: current_user.present? ? current_user.idUser : nil ,idClient: client.idClient},{idQuote: params[:quote]})
     if !carList.nil?
      carList.each do |car, val|
        return respond_json({:error => "The type of vehicle was not selected"}) if (carList[car]["car"] == "")
        return respond_json({:error => "The missing wheels was not selected"}) if (carList[car]["missingWheels"] == "")
        return respond_json({:error => "The missing battery was not selected: [" + carList[car]["missingBattery"] + "]"}) if (carList[car]["missingBattery"] == "")
        return respond_json({:error => "The address was not selected properly"}) if (carList[car]["addressId"] == "" && carList[car]["carPostal"] == "")
        updateCarForAddress(carList[car], client)
      end
      return respond_json({message: "QuickQuote saved"})
     else
       return respond_json({error: "Please select atleast one car"})
     end

  end

  def updateCarForAddress(car, client)
    addressId = car["idAddress"].nil? ? car["idAddress"] : car["idAddress"].to_i
    if addressId.kind_of? Integer
      updateQuoteCar(car, addressId.to_i)
    elsif (!car["carPostal"])
      updateQuoteCar(car, nil)
    elsif (car["carPostal"] && car["carPostal"] != "")
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
end