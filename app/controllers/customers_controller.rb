class CustomersController < ApplicationController
  before_action :login_required

  def new
    @customer = Customer.new
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
    addresses = ApiCall.get("/clients/#{params[:customerId]}/postal?search=#{s}", {}, headers)
    returned = {
        results: [],
        pagination: {
            more: true
        }
    }
    addresses.each do |address|
      t = ""
      t += address["address"] + ", " if address["address"] && address["address"] != ""
      t += address["city"] + ", " if address["city"] && address["city"] != ""
      t += address["province"] + ", " if address["province"] && address["province"] != ""
      returned[:results].push({id: address["idAddress"], text: t+ address["postal"]})
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
  end

  def update
    res = ApiCall.patch("/clients/"+params[:id], Customer.form_body(params), headers)
    growl(response_msg(res), "update")
    redirect_to customers_path
  end

  def get_customer
    res = ApiCall.get("/clients/#{params[:no]}", {}, headers)
    cus = JSON.parse(res)
    customer = Customer.where(phone: cus["phone"])
    if customer.first.quotes.present?
      cus["has_quote"] = true
      res = cus.to_json
    end
    respond_json(res)
  end

  private

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
