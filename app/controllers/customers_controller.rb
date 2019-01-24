class CustomersController < ApplicationController
  before_action :login_required

  def new
    @customer = Customer.new
    @heard_of_us = all_heard_of_use
  end

  def create
    res = ApiCall.post("/clients", Customer.form_body(params), headers )
    growl(response_msg(res), "create")
    redirect_to customers_path
  end

  def index
    @customers = ApiCall.get("/clients",{}, headers)
  end

  def postal_list
    s = params[:search] || ""
    addresses =  Address.select('idAddress AS id, idClient, address, city, province, distance, postal').where('postal LIKE ? and idClient = ?', s, params[:customer_id])

    returned = {
        results: [],
        pagination: {
            more: true
        }
    }
    addresses.each do |address|
      t = ""
      t += address.address + ", " if address.address && address.address != ""
      t += address.city + ", " if address.city && address.city != ""
      t += address.province + ", " if address.province && address.province != ""
      returned[:results].push({id: address.idAddress, text: t+ address.postal})
    end
    respond_json(returned)
  end

  def show
    @customer = JSON.parse(ApiCall.get("/clients/#{params[:id]}", { no: params[:id] }, headers))
    @quotes = JSON.parse(ApiCall.get("/clients/#{params[:id]}/quotes", {}, headers))
    @status = ApiCall.get("/status", {}, headers)
  end

  def edit
    @customer = Customer.find_by_id(params[:id])
    @heard = Heardofus.find_by_id(@customer.idHeardOfUs)
    @heard_of_us = all_heard_of_use
  end

  def update
    res = ApiCall.patch("/clients/"+params[:id], Customer.form_body(params), headers)
    growl(response_msg(res), "update")
    redirect_to customers_path
  end

  def get_customer
    customer = Customer.includes(:address,:heardofus,:quotes,business: [:contacts]).where(idClient: params[:no]).first
    cus = JSON.parse(customer.to_json(include: [:address,:heardofus,:quotes, business: {include: :contacts}]))
    cus["has_quote"] = true   if customer.quotes.present?
    respond_json(cus)
  end

  private

  def all_heard_of_use
    Heardofus.all
  end

  def growl(res, action)
    notice = "Customer is now edited!"
    if action == "create"
      notice = "Customer is created successfully!"
    end
    if res == true
      flash[:success] = notice
    else
      flash[:alert] = res
    end
  end

  def response_msg(res)
    result = ""
    if res["idClient"].present?
      result = true
    elsif res["error"].present?
      result = res["error"]
    end
    result
  end

end
