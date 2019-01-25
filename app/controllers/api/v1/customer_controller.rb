class Api::V1::CustomerController < ApiController
  include ActionView::Helpers::NumberHelper
  include Customers
  before_action :authenticate_user, except: [:index]
	# before_action :authenticate_admin

  def create
    if check_params
      render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    elsif required_params
      render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    else
      client = create_customer(params, current_user)
      if client != false
        return render_json_response(client, :ok)
      else
        render_json_response({:error => ALREADY_EXISTS, :success => false}, :unprocessable_entity)
      end
    end
  end

  def index
    offset = 0
    filter = "%"
    offset = params[:offset].to_i if params[:offset] && to_number(params[:offset])
    filter = "%" + params[:filter] + "%" if params[:filter]    
    lstClients = Customer.includes(:address, :heardofus).where("firstName LIKE ? or lastName LIKE ? or type LIKE ? or email LIKE ? OR phone LIKE ? or extension LIKE ? OR cellPhone LIKE ? or secondaryPhone LIKE ? OR grade LIKE ? or note LIKE ?", filter,filter,filter,filter,filter,filter,filter,filter,filter,filter).order("firstName ASC, LastName ASC").limit(30).offset(offset).to_json(include: [:address, :heardofus])
    return render json: lstClients, status: :ok, adapter: :json_api
  end

  def show
    puts 'Edit Screen API'
    client = Customer.includes(:address,:heardofus,business: [:contacts]).where(idClient: params[:no]).first.to_json(include: [:address,:heardofus,business: {include: :contacts}])
    if client
      return render_json_response(client, :ok)
    else
      render_json_response({:error => CLIENT_NOT_FOUND, :success => false}, :not_found)
    end
  end

  def update
    if check_params
      render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    elsif required_params
      render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    else
      response = update_customer(params, current_user)
      if response != false
          return render_json_response(response, :ok)
      else
        render_json_response({:error => CLIENT_NOT_FOUND, :success => false}, :not_found)
      end
    end
  end

  def phones
    if  params[:search].present?
     phones = Customer.where('phone LIKE ? OR cellPhone LIKE ? OR secondaryPhone LIKE ?', params[:search] + "%", params[:search] + "%", params[:search] + "%").limit(params[:limit].to_i).offset(params[:offset].to_i * params[:limit].to_i)
     return render_json_response(phones, :ok) if !phones.empty?
    end
    return render_json_response([], :ok)
  end

  def client_phones
    client = Customer.includes(:address).where(phone: params[:phone]).first.to_json(:address)
    return render_json_response(client, :ok) if client.present?
    return render_json_response({:error => CLIENT_NOT_FOUND, :success => false}, :not_found)
  end

  def heardofus
    count = Customer.joins(:heardofus).select("heardsofus.type ").group("idHeardOfUs")
    last_data = []
    letters = [*'0'..'9',*'A'..'F']
    color = ""
    count.each.with_index(1) do |counter, index|
      color = "#"
      color+=(0...6).map{ letters.sample }.join
      last_data.push({label: counter["type"],
                     data: index,
                     color: color})
    end
    return render_json_response(last_data, :ok)
  end

  def postal
    addresses = Address.select('idAddress AS id, idClient, address, city, province, distance, postal').where('postal LIKE ? and idClient = ?', params[:search], params[:customer_id])
    return render_json_response(addresses, :ok)
  end
	
  private 


  def get_address(formatted_address)
    twoAddress = "7628 Flewellyn Rd Stittsville, ON, K2S 1B6|" + formatted_address;
    url = "https://maps.googleapis.com/maps/api/distancematrix/json?key=#{ENV['GOOGLE_MAP_TOKEN']}&origins=#{twoAddress}&destinations=#{twoAddress}"
    response = HTTParty.get(url)
    response.body
  end

  def check_address(distance)
    distance["rows"] && distance["rows"].length == 2 && distance["rows"][0]["elements"] && distance["rows"][0]["elements"][1]["status"] == "OK"
  end

end
