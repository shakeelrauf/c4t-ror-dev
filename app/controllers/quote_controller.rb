class QuoteController < ApplicationController
  before_action :login_required

	def all_quotes  
    @quotes = Quote.includes(customer: [:address]).all
    @status = Status.all
  end

  def quote_with_filter
    res = ApiCall.get("/quotes/json?limit=#{params[:limit]}
                  &offset=#{params[:offset]}&afterDate=#{params[:afterDate]}&beforeDate=#{params[:beforeDate]}&filter=#{params[:filter]}",{} , headers )
    respond_json(res)
  end

  def vehicle_list
    vehicles = ApiCall.get("/vehicles?filter=#{params[:q]}&offset=#{params[:offset]}", {},headers)
    groups, item = [], {}
    vehicles.each do |vehicle|
      if vehicle["make"] == "Other"
        item["text"]= "Other"
      else
        item["text"] = vehicle["make"] + " "
        +  vehicle["year"] + " "
        + vehicle["model"] + " "
        + vehicle["body"] + " "
        + vehicle["trim"] + " "
        + vehicle["transmission"] + " "
        + vehicle["drive"] + " "
        + vehicle["doors"] + " doors and "
        + vehicle["seats"] + " seats.";
        item["id"] = vehicle["id"]
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

  def phone_list
    phones =  ApiCall.get("/client/phones?search=#{params[:search]}&limit=#{params[:limit]}&offset=#{params[:offset]}",{}, headers)
    returned = {
        results: [],
        pagination: {
            more: true
        }
    }
    returned[:pagination][:more] = false if phones.length < params[:limit].to_i
    phones.each do |phone|
      client = JSON.parse ApiCall.get("/clients/#{phone["idClient"]}", {}, headers)

      client["phone"] =  client["cellPhone"] if client["phone"].match(params[:search]) && client["cellPhone"].match(params[:search])
      client["phone"] =  client["secondaryPhone"] if client["phone"].match(params[:search]) && client["secondaryPhone"].match(params[:search])
      returned[:results].push({
                                 id: phone["idClient"],
                                 text: client["phone"][0,3].to_s + " " + client["phone"][3,3].to_s+ "-" + client["phone"][6,10].to_s +
                                     " " + client["firstName"].to_s + " " + client["lastName"].to_s
                             })
      if client["business"]
        client["business"]["contacts"].each do |contact|
          returned[:results].push({
                                      id: phone["idClient"],
                                      text: client["phone"][0,3].to_s + " " + client["phone"][3,3].to_s+ "-" + client["phone"][6,10].to_s +
                                          " " + contact["firstName"].to_s + " " + contact["lastName"].to_s
                                  })
        end
      end
    end
    respond_json(returned)
  end

  def create_quotes
		@status = Status.all
		@heardsofus = Heardofus.all
		@customers = Customer.all
		@user = User.all
		@charities = Charitie.all
  end

	def edit_quotes
    @quote = ApiCall.get("/quotes/#{params[:id]}", {}, headers)
    cars = ApiCall.get("/quotes/#{params[:id]}/cars", {}, headers)
    @charities = ApiCall.get("/charities",{}, headers)
    @heardsofus = ApiCall.get("/heardsofus", {}, headers)
    carsFormated = []
    cars.length.times do |i|
      cars[i]["vehicle"] = cars[i]["information"]
      if cars[i]["address"]
        cars[i]["address"]["label"] = "";
        cars[i]["address"]["label"] += (cars[i]["address"]["address"] && cars[i]["address"]["address"] != "") ? cars[i]["address"]["address"] + " " : ""
        cars[i]["address"]["label"] += (cars[i]["address"]["city"] && cars[i]["address"]["city"] != "") ? cars[i]["address"]["city"] + ", " : ""
        cars[i]["address"]["label"] += (cars[i]["address"]["province"] && cars[i]["address"]["province"] != "") ? cars[i]["address"]["province"] + " " : ""
        cars[i]["address"]["label"] += (cars[i]["address"]["postal"] && cars[i]["address"]["postal"] != "") ? cars[i]["address"]["postal"] + " " : ""
      end
      carsFormated.push(cars[i])
    end
    render  locals: {
                       req: request,
                       user: current_user,
                       quote: JSON.parse(@quote.to_json),
                       cars: carsFormated,
                       charities: JSON.parse(@charities.to_json),
                       heardsofus: JSON.parse(@heardsofus.to_json)
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
      quotes = Quote.includes(:customer).where(idQuote: params[:no])
      if quotes.present?
        results = quotes.first.update(
          idStatus: params[:status],
          dtStatusUpdated: Time.now
        )
      end
      r_quote = Quote.includes(:customer).where(idQuote: params[:no])
      # If status is «in Yard», send sms to customer for know his appreciation.
      if (params[:status] == 6)
        # Check if sms already sent.
        if (!r_quote.first.isSatisfactionSMSQuoteSent && r_quote.first.customer.cellPhone)
          sms = TwilioTextMessenger.new "Hello. This is CashForTrash. We recently bought your car. We want to know your satisfaction. On a scale of 1 to 10, how much did you appreciate our service? Please respond with a number.", "4388241370"
          sms.call
          quotes.first.update(isSatisfactionSMSQuoteSent: 1)
        end
      end
    end
  end

end
