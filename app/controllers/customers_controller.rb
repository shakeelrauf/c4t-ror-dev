class CustomersController < ApplicationController
  before_action :login_required

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
    res = ApiCall.patch("/clients/"+params[:id], form_body(params), headers)
    render json: { response: res }
  end

  def get_customer
    res = ApiCall.get("/clients/#{params[:no]}", {}, headers)
    respond_json(res)
  end

  private

  def form_body(params)
    {
      "heardOfUs":      params[:heardOfUs],
      "phoneNumber":    params[:phoneNumber],
      "firstName":      params[:firstName],
      "lastName":       params[:lastName],
      "email":          params[:email],
      "type":           params[:type],
      "extension":      params[:extension],
      "phoneNumber2":   params[:phoneNumber2],
      "phoneNumber3":   params[:phoneNumber3],
      "note":           params[:note],
      "grade":          params[:grade],
      "address":        params[:address],
      "city":           params[:city],
      "province":       params[:province],
      "postal":         params[:postal],
      "addresses":      address_data(params),
      "contacts":       contact_data(params)
    }.merge(company_data(params))
  end

  def address_data(params)
    addresses = []
    if params[:addresses].present?
      p_key = params[:addresses]
      p_key["address"].zip(p_key["city"], p_key["province"], p_key["postal"]).each do |adr, city, pro, pos|
        addresses << {
                        "address":  adr,
                        "city":     city,
                        "province": pro,
                        "postal":   pos
                      }
      end
    end
    addresses
  end

  def company_data(params)
    {
      "name":             params[:name],
      "description":      params[:description],
      "contactPosition":  params[:contactPosition],
      "pstTaxNo":         params[:pstTaxNo],
      "gstTaxNo":         params[:gstTaxNo]
    }
  end

  def contact_data(params)
    contacts = []
    if params[:contacts].present?
      p_key = params[:contacts]
      p_key["firstName"].zip(p_key["lastName"], p_key["paymentMethod"]).each do |fn, ln, pm|
        contacts << { "firstName":     fn,
                      "lastName":      ln,
                      "paymentMethod": pm
                    }
      end
    end
    contacts
  end

end
