class CustomersController < ApplicationController
  before_action :login_required
  include Customers
  include Api::V1::MsgsConst
  include Api::V1::Request

  def new
    @customer = Customer.new
    @heard_of_us = all_heard_of_use
  end

  def create
    if check_params
      required_params_error(false)
    elsif required_params
      required_params_error(false)
    else
      client = create_customer(Customer.form_body(params), current_user)
      if client != false
        growl("create")
      else
        required_params_error(true)
      end
    end
  end

  def index
    @customers = Customer.includes(:address, :heardofus).order("firstName ASC, LastName ASC").limit(30)
  end

  def postal_list
    s = params[:search] || ""
    addresses =  Address.where('idClient = ?', params[:customerId])
    returned = {
        results: [],
        pagination: {
            more: false
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
    if check_params
      required_params_error(false)
    elsif required_params
      required_params_error(false)
    else
      response = update_customer(Customer.form_body(params), current_user, params[:id])
      if response != false
        growl("update")
      else
        flash[:alert] = CLIENT_NOT_FOUND
        redirect_to customers_path
      end
    end
  end

  def get_customer
    customer = Customer.includes(:address,:heardofus,:quotes,business: [:contacts]).where(idClient: params[:no]).first
    cus = JSON.parse(customer.to_json(include: [:address,:heardofus,:quotes, business: {include: :contacts}]))
    cus["has_quote"] = true   if customer.quotes.present?
    respond_json(cus)
  end

  def number_exist
    client = Customer.where(phone: params[:phone]).count
    render json: { client: client }
  end

  private

  def growl(action)
    notice = "Customer is now edited!"
    if action == "create"
      notice = "Customer is created successfully!"
    end
    flash[:success] = notice
    redirect_to customers_path 
  end

  def required_params_error(type)
    notice = REQUIRED_ATTRIBUTES
    if type == true
      notice = ALREADY_EXISTS
    end
    flash[:alert] = notice
    redirect_to customers_path
  end

  def all_heard_of_use
    Heardofus.all
  end

end
