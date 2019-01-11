class Api::V1::QoutecarsController < ApiController
	# before_action :authenticate_user

	def quotescars
		list = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
		render json: JSON.parse(list), status: :ok, adapter: :json_api
 	end

 	def show
 		qc = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).first.where(idQuoteCars: params[:carNo]).to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
		render json: JSON.parse(qc), status: :ok, adapter: :json_api
	end

	def list
		qc = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuote: params[:quoteNo]).to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
		render json: JSON.parse(qc), status: :ok, adapter: :json_api
	end

	def list_cars
		if params[:limit] && params[:offset]
			limit =  params[:limit].gsub("?","").to_i
			offset = limit * params[:offset].to_i
			cars = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).limit(limit).offset(offset).to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
		else
			cars = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
		end
		render json: JSON.parse(cars), status: :ok, adapter: :json_api
	end
	
	def list_cars_count
		cars = QuoteCar.count
		render json: JSON.parse({count: cars}.to_json), status: :ok, adapter: :json_api
	end
end
