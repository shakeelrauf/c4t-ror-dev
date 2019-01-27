module Quotesmethods
  include Distancemethods
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
    client = Customer.custom_upsert({idHeardOfUs: heard_of_us.idHeardOfUs,phone: phone,firstName: params[:firstName],lastName: params[:lastName]},{phone: phone})
    client.address.first.update(postal: params[:postal])
    Quote.custom_upsert({note: params[:note],idUser: current_user.present? ? current_user.idUser : nil ,idClient: client.idClient},{idQuote: params[:quote]})
    if !carList.nil?
      carList.each do |car, val|
        return respond_json({:error => "The type of vehicle was not selected"}) if (!carList[car]["car"].present?)
        return respond_json({:error => "The missing wheels was not selected"}) if (carList[car]["missingWheels"] == "")
        return respond_json({:error => "The missing battery was not selected: [" + carList[car]["missingBattery"] + "]"}) if (carList[car]["missingBattery"] == "")
        return respond_json({:error => "The address was not selected properly"}) if (carList[car]["carAddressId"] == "" && carList[car]["carPostal"] == "")
        return respond_json({:error => "Missing Car city"}) if  (!carList[car]["carCity"].present?)
        return respond_json({:error => "Missing Car Street"}) if  (!carList[car]["carStreet"].present?)
        return respond_json({:error => "Missing Car Province"}) if  (!carList[car]["carProvince"].present?)
        car_postal_code = Validations.postal(carList[car]["carAddressId"])
        return respond_json({:error => "Invalid Car Postal Code"}) if  (car_postal_code.length != 7)
        quote_car = QuoteCar.where(idQuoteCars: carList[car]["car"]).first
        quote_car.update(missingBattery: carList[car]["missingBattery"],missingCat: carList[car]["missingCat"],gettingMethod: carList[car]["gettingMethod"],missingWheels: carList[car]["missingWheels"], still_driving: carList[car]["still_driving"] ) if quote_car.present?
        update_quote_car_address carList[car], quote_car, client if carList[car]["carAddressId"].present?
      end
      return respond_json({message: "QuickQuote saved"})
     else
       return respond_json({error: "Please select atleast one car"})
     end
  end

  def search_quotes limit_p, offset_p, filter,after_date, before_date
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
        query+= "('note' like '#{fil}' OR referNo like '#{fil}' OR Clients.firstName like '#{fil}' OR Clients.lastName like '#{fil}' OR Clients.phone like '#{fil}' OR Clients.cellPhone like '#{fil}' OR Clients.secondaryPhone like '#{fil}' OR Users.firstName like '#{fil}' OR Users.lastName like '#{fil}' OR Status.name like '#{fil}')"
        query+= " AND " if i < (length -1)
      end
      # query = "(#{query}) AND (('dtCreated' <= '#{after_date+ ' 00:00:00'}') AND ('dtCreated' >= '#{before_date+ ' 23:59:59'}'))" if after_date && after_date.to_s.length == 10 && DateTime.parse(after_date, "YYYY-MM-DD")
      @quotes =  Quote.eager_load(:status, :customer, :dispatcher).where(query)
      if @quotes.count % 15 > 0
        all_count = 1
      end
      all_count += (@quotes.count / limit.to_i).ceil
      @quotes = @quotes.limit(limit).offset(offset).to_json(include: [:dispatcher, :customer, :status])
    else
      @quotes =  Quote.includes(:dispatcher, :customer, :status)
      if @quotes.count % 15 > 0
        all_count = 1
      end
      all_count += (@quotes.count / limit.to_i).ceil
      @quotes = @quotes.limit(limit).offset(offset).to_json(include: [:dispatcher, :customer, :status])
    end
    return @quotes, all_count
  end

  def update_quote_car_address car, quote_car, client
    if quote_car.address.present?
      ad = quote_car.address
    else
      ad = Address.new
    end
    res = car["distance"]
    ad.postal = car["carAddressId"]
    ad.city = car["carCity"]
    ad.province = car["carProvince"]
    ad.address = car["carStreet"]
    ad.idClient = client.id
    ad.distance = res
    ad.save!
    quote_car.idAddress = ad.idAddress
    quote_car.save!
  end
end