class Api::V1::QuoteController < ApiController
	before_action :authenticate_user

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
    	
    db.query("SELECT * FROM Settings WHERE dtCreated IN (SELECT MAX(dtCreated) FROM Settings GROUP BY name)", {
      type: db.QueryTypes.SELECT
    }).then(settings => {

    # The settings hash
    s = {}
    settings.each do |setting|
      s[setting.name] = setting.value
    end

    count = Quote.where(dtCreated: moment().format("YYYY-MM-01 00:00:00")
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
    })
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
    .delete('/quotes/:no', [oauth], (req, res) => {
      quotes.destroy({
        where: {
          id: req.params.no
        }
      }).then((results) => {
        res.json({
          "message": "Quote deleted!"
        })
      })
    })

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

  # get one quote
  def quote
  	@quote = Quote.includes(:user, :client => [:address, :heardofus], :status).find_by_id(id: params[:no]).to_json(include: [:dispatcher,:status, {customer: {:include => [:address, :heardofus]}}])
	  if (!@quote)
			return render_json_response({:message => "Quote not found!"}, :ok)
	  else {
	    @quote_car = QuoteCar.includes(:address).where(idQuote: params[:no]).to_json(include: [:address])
	    @quote.dataValues.cars = @quote_car
			return render_json_response(@quote, :ok)
		end
	end

end
