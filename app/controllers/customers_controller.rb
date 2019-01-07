class CustomersController < ApplicationController
  # before_action :login_required


  def new
    @customer = Customer.new
  end

  def create
    res = ApiCall.post("/clients", form_body(params), headers )
    render json: { response: res }
  end

  def index
    @customers = ApiCall.get("/clients",{}, headers)
  end

  def show
    @customer = JSON.parse(ApiCall.get("/clients/#{params[:id]}", { no: params[:id] }, headers)).first
    @quotes = JSON.parse(ApiCall.get("/clients/#{params[:id]}/quotes", {}, headers))
    @status = ApiCall.get("/status", {}, headers)
  end

  private

  def form_body(params)
    {
      "heardOfUs": params[:heardOfUs],
      "phoneNumber": params[:phoneNumber],
      "firstName": params[:firstName],
      "lastName": params[:lastName],
      "email": params[:email],
      "type": params[:type],
      "extension": params[:extension],
      "phoneNumber2": params[:phoneNumber2],
      "phoneNumber3": params[:phoneNumber3],
      "note": params[:note],
      "grade": params[:grade],
      "address": params[:address],
      "city": params[:city],
      "province": params[:province],
      "postal": params[:postal],
      "addresses": address_data(params)
    }
  end

  def address_data(params)
    [{
      "address": params[:address],
      "city": params[:city],
      "province": params[:province],
      "postal": params[:postal]
    }]
  end

  def get_customer
    res = ApiCall.get("/clients/#{params[:no]}", {}, headers)
    respond_json(res)
  end
end
