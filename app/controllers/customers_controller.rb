class CustomersController < ApplicationController
  before_action :login_required
  include Growl
  include Customers

  def new
    @customer = Customer.new
    @heard_of_us = all_heard_of_use
  end

  def create
    res = ApiCall.post("/clients", Customer.form_body(params), headers )
    growl(response_msg(res, "idClient"), "create", "Customer")
    redirect_to customers_path
  end

  def index
    @customers = Customer.includes(:address, :heardofus).order("firstName ASC, LastName ASC").limit(30)
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
    @customer = Customer.includes(:address,:heardofus,business: [:contacts]).where(idClient: params[:id]).first
    @quotes = Quote.includes(:dispatcher, :customer, :status).where(idClient: params[:id]).order('dtCreated DESC').limit(30)
    @status = Status.all
  end

  def edit
    @customer = Customer.find_by_id(params[:id])
    @heard = Heardofus.find_by_id(@customer.idHeardOfUs)
    @heard_of_us = all_heard_of_use
  end

  def update
    res = ApiCall.patch("/clients/"+params[:id], Customer.form_body(params), headers)
    growl(response_msg(res, "idClient"), "update", "Customer")
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

end
