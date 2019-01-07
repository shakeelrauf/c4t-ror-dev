class QuoteController < ApplicationController

	def all_quotes  
    @quotes = Quote.includes(customer: [:address]).all
    @status = Status.all
  end

	def create_quotes
		@status = Status.all
		@heardsofus = Heardofus.all
		@customers = Customer.all
		@user = User.all
		@charities = Charitie.all
  end

	def edit_quotes
		@quote = Quote.find(params[:id])
		@heardsofus = Heardofus.all
		@cars = QuoteCar.all
  end
end
