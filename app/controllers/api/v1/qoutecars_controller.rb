class Api::V1::QoutecarsController < ApiController
	before_action :authenticate_user

	def quotescars
		list = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
		render json: list, status: :ok, adapter: :json_api
 	end

 	def show
 		qc = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuoteCars: params[:carNo]).first.to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
		render json: qc, status: :ok, adapter: :json_api
 	end

 	def list
 		cars = QuoteCar.includes([:information, :address, :quote => [:customer, :dispatcher, :status]]).where(idQuote: params[:quoteNo]).first.to_json(include: [:address,:information, {quote: {:include => [:customer, :dispatcher, :status]}}])
		render json: cars, status: :ok, adapter: :json_api
 	end
end
