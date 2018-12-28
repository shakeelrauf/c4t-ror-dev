class Api::V1::QuickQuoteController < ApiController
	
	def updateCarForAddress(car, client, next) {
     # If the addressId is an int, it's an addressId, else it's a postal
    addressId = car.carAddressId

    if addressId.kind_of? Integer
      # It's a number
      updateQuoteCar(car, addressId.to_i, next);

    elsif (!car.carPostal)
       # No address at this time
      updateQuoteCar(car, nil, next);

    elsif (car.carPostal && car.carPostal != "")
       # We can create a new address
      Address.create(
          idClient: client.id,
          address:  car.carStreet,
          city:     car.carCity,
          postal:   car.carPostal,
          province: car.carProvince,
          distance: car.distance
      )
        updateQuoteCar(car, Address.last.id, next);
      end
  end

   # The update of a quote car
  def updateQuoteCar(car, addressId, next)
    console.log("==================> QuoteCar.update    : " + JSON.stringify(car));
    console.log("==================> QuoteCar.update    : " + parseInt(car.car));
    QuoteCar.update(
        idAddress: addressId,
        missingWheels: car.missingWheels.present? ? car.missingWheels.to_i : 0,
        missingBattery: (car.missingBattery && car.missingBattery == 1),
        missingCat: (car.missingCat && car.missingCat == 1),
        gettingMethod: car.gettingMethod,
        distance: (car.distance.present? ? car.distance.to_f : nil),
        price: (car.price.present? ? car.price.to_f : nil)
    )
    next();
  end


  #   def index
  #     QuickQuote.findAll({
  #       include: [{
  #         model: User,
  #         as: "dispatcher"
  #       }, {
  #         model: HeardOfUs,
  #         as: "heardofus"
  #       }]
  #     }).then(quickquotes => {
  #       res.json(quickquotes);
  #     });
  #   end

  # def respond400Message(res, msg) {
  #   res.status(400);
  #   res.json({"error": msg});
  # end

end
