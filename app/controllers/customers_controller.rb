class CustomersController < ApplicationController
  # before_action :authenticate_user

  def index
    begin
      @customers = ApiCall.get("/clients",{})
    rescue Net::ReadTimeout
      @customers = []
    end
  end

  def show
    id = params[:id]
    begin
      customer_data = ApiCall.get("/clients/#{id}",{no: id})
      quote_data = ApiCall.get("/clients/#{id}/quotes",{})
      @status = ApiCall.get("/status",{})
      @customer = JSON.parse(customer_data).first
      @quotes = JSON.parse(quote_data)
    rescue Net::ReadTimeout
      @customer = []
    end  
  end

end
