class CustomersController < ApplicationController
  # before_action :authenticate_user


  def new
    @customer = Customer.new
  end

  def index
    begin
      @customers = ApiCall.get("/clients",{})
    rescue Net::ReadTimeout
      @customers = []
    end
  end

  def show
    @customer = JSON.parse(ApiCall.get("/clients/#{params[:id]}",{no: params[:id]})).first
    @quotes = JSON.parse(ApiCall.get("/clients/#{params[:id]}/quotes",{}))
    @status = ApiCall.get("/status",{})
  end

end
