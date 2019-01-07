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
          quotes.update(isSatisfactionSMSQuoteSent: 1)
        end
      end
    end
  end

end
