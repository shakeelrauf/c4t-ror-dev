class Api::V1::QuoteController < ApiController
	before_action :authenticate_user, except: [:particular_customer_quotes,:all_status, :update_quote_status]
  include ActionView::Helpers::NumberHelper

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
	  return render_json_response(@car, :ok)
  end

  def get_quotes_by_filters
    limit = 100
    offset = 0
    limit  = params[:limit] if params[:limit].to_i > 0
    offset  = params[:offset] if params[:offset].to_i > 0
    query =  "SELECT * from Quotes "
    if params[:filter]
      params[:filter] = "%" + params[:filter].gsub(/[\s]/, "% %").gsub('?','') + "%"
      filters =  params[:filter].split(' ')
      length =  filters.length
      filters.each.with_index do |fil,i|
        query+= "INNER JOIN Status ON status.idStatus = quotes.idStatus INNER JOIN users ON users.idUser = quotes.idUser INNER JOIN clients ON clients.idClient = quotes.idClient WHERE" if i == 0
        query+= " ('note' LIKE '#{fil}' OR 'referNo' LIKE '#{fil}' OR 'clients.firstName' LIKE '#{fil}' OR 'clients.lastName' LIKE '#{fil}' OR 'clients.phone' LIKE '#{fil}' OR 'clients.cellPhone' LIKE '#{fil}' OR 'clients.secondaryPhone' LIKE '#{fil}' OR 'users.firstName' LIKE '#{fil}' OR 'users.lastName' LIKE '#{fil}' OR 'status.name' LIKE '#{fil}')"
        query+= " AND" if i < (length -1)
      end
      # query+= " AND 'dtCreated' <= '#{params[:afterDate]+ ' 00:00:00'}'" if params[:afterDate] && params[:afterDate].to_s.length == 10 && DateTime.parse(params[:afterDate], "YYYY-MM-DD")
      # query+= " AND 'dtCreated' <= '#{params[:beforeDate]+ ' 23:59:59'}'" if params[:beforeDate] && params[:beforeDate].to_s.length == 10 && DateTime.parse(params[:beforeDate], "YYYY-MM-DD")
      @quotes = Quote.run_sql_query(query)
      @quotes =  Quote.includes(:dispatcher, :customer,:status).where('idQuote IN (?)', @quotes.pluck("idQuote")).to_json(include: [:dispatcher, :customer, :status])
    else
      @quotes =  Quote.includes(:dispatcher, :customer, :status).to_json(include: [:dispatcher, :customer, :status])
    end
    return render_json_response(@quotes, :ok)
  end

  def quote_with_filter
    limit = 15
    offset = 0
    all_count = 0
    limit  = params[:limit].delete(' ') if params[:limit].to_i > 0
    offset = ((params[:offset].to_i) * limit.to_i) if params[:offset] != "-1"
    query =  ""
    if params[:filter]
      params[:filter] = "%" + params[:filter].gsub(/[\s]/, "% %").gsub('?','') + "%"
      filters =  params[:filter].split(' ')
      length =  filters.length
      filters.each.with_index do |fil,i|
        query+= "('note' like '#{fil}' OR referNo like '#{fil}' OR clients.firstName like '#{fil}' OR clients.lastName like '#{fil}' OR clients.phone like '#{fil}' OR clients.cellPhone like '#{fil}' OR clients.secondaryPhone like '#{fil}' OR users.firstName like '#{fil}' OR users.lastName like '#{fil}' OR status.name like '#{fil}')"
        query+= " AND " if i < (length -1)
      end
      # query = "(#{query}) AND (('dtCreated' <= '#{params[:afterDate]+ ' 00:00:00'}') AND ('dtCreated' >= '#{params[:beforeDate]+ ' 23:59:59'}'))" if params[:afterDate] && params[:afterDate].to_s.length == 10 && DateTime.parse(params[:afterDate], "YYYY-MM-DD")
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
    render json: { quotes: JSON.parse(@quotes), count: all_count}
  end


    # Creates a blank quote
  def create
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
    return render_json_response(quote, :ok)
  end

  # Creates a blank quote ca
  def remove_car
  	@quote_car = QuoteCar.where(id: params[:car])
    @quote_car.destroy
    return render_json_response({:msg => "ok"}, :ok)
  end

  def show
    quote = JSON.parse Quote.includes(:dispatcher,customer: [:address,:heardofus]).where(idQuote: params[:no]).first.to_json(include: [:dispatcher,{:customer => {include: [:address, :heardofus]}}])
    return render_json_response({error: "not found"}, :not_found) if quote.nil?
    cars = JSON.parse QuoteCar.where(idQuote: params[:no]).to_json
    quote["cars"] = cars
    render json: quote, status: :ok, adapter: :json_api
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
          @quote.first.idStatus = params[:status]
          @quote.first.dtStatusUpdated = Time.now
          @quote.first.save(:validate => false)
          result = @quote
        else
          return render_json_response({"msg": "Failure!!", "success": false,:error => "Status not found"}, :ok)
        end
        r_quote = Quote.includes(:customer).find_by_id(id: params[:no])
        # If status is ??in Yard??, send sms to customer for know his appreciation.
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
      # quotes = Quote.includes(:customer).find_by_id(id: params[:no]) #prev
      quotes = Quote.includes(:customer).find(params[:no])
      if quotes.present?
        results = quotes.update(
          idStatus: params[:status],
          dtStatusUpdated: Time.now
        )
      end
      r_quote = Quote.includes(:customer).find_by_id(id: params[:no])
      # If status is ??in Yard??, send sms to customer for know his appreciation.
      if (params[:status] == 6)
        # Check if sms already sent.
        if (!r_quote.isSatisfactionSMSQuoteSent && r_quote.customer.cellPhone)
          # sms = TwilioTextMessenger.new "Hello. This is CashForTrash. We recently bought your car. We want to know your satisfaction. On a scale of 1 to 10, how much did you appreciate our service? Please respond with a number.", "4388241370"
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
    # lstQuotes = Quote.includes(:dispatcher, :customer, :status).order('dtCreated DESC').offset(offset).limit(30).to_json(include: [:dispatcher, :customer, :status])
    # it should be this query which is written down
    lstQuotes = Quote.includes(:dispatcher, :customer, :status).where(idClient: params[:no]).order('dtCreated DESC').offset(offset).limit(30).to_json(include: [:dispatcher, :customer, :status])
    # lstQuotes = Quote.includes(:dispatcher, :customer, :status).where("(note like ?  OR status.name LIKE ? OR dispatcher.firstName LIKE ? OR dispatcher.lastName LIKE ? OR reference  LIKE ? ) AND idClient = ?", filter, filter, filter, filter, filter, params[:no]).order('DESC').offset(offset).limit(30)

    # lstQuotes.each do |quote|
    #   # TODO! Format each quote before send it.
    # end
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
