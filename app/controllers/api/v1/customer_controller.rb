class Api::V1::CustomerController < ApiController
  include ActionView::Helpers::NumberHelper
	before_action :authenticate_user

  def create
    if check_params
      render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    elsif required_params
      render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    else
      customDollarCar = 0
      customDollarSteel = 0
      customPercCar = 0
      customPercSteel = 0

      if current_user.roles.eql?("admin") 
        customDollarCar = params[:customDollarCar] if params[:customDollarCar]
        customDollarSteel = params[:customDollarSteel] if params[:customDollarSteel]
        customPercCar = params[:customPercCar] if params[:customPercCar]
        customPercSteel = params[:customPercSteel] if params[:customPercSteel]
      end

      heardofus = Heardofus.find_or_create_by(type: params[:heardOfUs])
      if heardofus.present?
        client = Customer.find_or_initialize_by(phone: params[:phoneNumber])
        if client.new_record?
          client.idHeardOfUs = heardofus.idHeardOfUs
          client.firstName= params[:firstName]
          client.lastName = params[:lastName]
          client.email= params[:email]
          client.type = params[:type]
          client.extension = params[:extension]
          client.cellPhone = params[:phoneNumber2]
          client.secondaryPhone = params[:phoneNumber3]
          client.note = params[:note]
          client.grade = params[:grade]
          client.customDollarCar = customDollarCar
          client.customDollarSteel = customDollarSteel
          client.customPercCar = customPercCar
          client.customPercSteel = customPercSteel
          client.save!
          params[:addresses].each do |a|
            puts "ADDRESS ADDING :: #{a["address"]}"
            newAddress = client.address.new( address: a["address"],city: a["city"],postal: a["postal"],province: a["province"].upcase)
            distance = get_distance(newAddress)
            newAddress.distance = (distance["rows"][0]["elements"][1]["distance"]["value"] + distance["rows"][1]["elements"][0]["distance"]["value"])
            newAddress.save!
            if !params[:company].eql?("0")
              busi = client.build_business({
                name: params[:name],
                description: params[:description],
                contactPosition: params[:contactPosition],
                pstTaxNo: params[:pstTaxNo],
                gstTaxNo: params[:gstTaxNo]})
              if busi.save
                client.business = {};
                comp = Business.where(params[:id]).first
                if comp.present?
                  client.business = comp
                  return render_json_response(client, :ok)
                end
              end
            else
              return render_json_response(client, :ok)
            end
          end
        else
          render_json_response({:error => ALREADY_EXISTS, :success => false}, :unprocessable_entity)
        end
      end
    end
  end

  def index
    return render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request) if !parma[:filter].present?
    offset = 0
    filter = "%"
    offset = params[:offset].to_i if params[:offset] && to_number(params[:offset])
    filter = "%" + params[:filter] + "%" if params[:filter]
    lstClients = Customer.includes(:address).where("firstName LIKE ? or lastName LIKE ? or type LIKE ? or email LIKE ? or phone LIKE ? extension LIKE ? OR cellPhone LIKE ? or secondaryPhone LIKE ? OR grade LIKE ? or note LIKE ?", filter,filter,filter,filter,filter,filter,filter,filter,filter,filter).order("firstName ASC, LastName ASC").limit(30).offset(offset).to_json(:address)
    return render json: lstClients, status: status, adapter: :json_api
  end

  def show
    puts 'Edit Screen API'
    client = Customer.where(idClient: params[:no]).first
    if client
      adresse = Address.where(idClient: client.id)
      client.address = adresse
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
      clientNote = Customer.where(idClient: params[:no]).first
      if !clientNote
        render_json_response({:error => CLIENT_NOT_FOUND, :success => false}, :not_found)
      else
        puts "Role:---------#{current_user.roles}"
        #Not admin can't edit previous notes. He can only add after.
        params[:type] = clientNote.type + "<br>" + params[:type].gsub(clientNote.type, "") if !current_user.roles.eql?("admin")
        formatted_address = params[:address] + " " + params[:city] + ", " + params[:province].upcase + ", " + params[:postal]
        puts "formatted_address:---------#{formatted_address}"
        #Calculate distance with google map.
        address = get_address(formatted_address)

        if address
          customDollarCar = 0
          customDollarSteel = 0
          customPercCar = 0
          customPercSteel = 0

          if current_user.roles.eql?("admin") 
            customDollarCar = params[:customDollarCar] if params[:customDollarCar]
            customDollarSteel = params[:customDollarSteel] if params[:customDollarSteel]
            customPercCar = params[:customPercCar] if params[:customPercCar]
            customPercSteel = params[:customPercSteel] if params[:customPercSteel]
          end

          heardofus = Heardofus.find_or_create_by(type: params[:heardOfUs])
          clientNote.update(idHeardOfUs: heardofus.id, firstName: params[:firstName], lastName: params[:lastName], email: params[:email],
              type: params[:type], phone: params[:phoneNumber], extension: params[:extension], cellPhone: params[:phoneNumber2], secondaryPhone: params[:phoneNumber3],
              note: params[:note], grade: params[:grade], customDollarCar: customDollarCar, customDollarSteel: customDollarSteel, customPercCar: customPercCar, customPercSteel: customPercSteel) if client.present
          params[:addresses].each do |a|
            return render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request) if  !address.address || !address.city || !address.postal || !address.province
          end
          params[:addresses].each do |a|
            if address.idAddress.eql?('')
              addresses = Address.where(idClient: params[:no], address: a["address"], city: a["city"], postal: a["postal"], province: a["province"].upcase,
                            idAddress: address.idAddress,
                            distance: distance["rows"][0]["elements"][1]["distance"]["value"] + distance["rows"][1]["elements"][0]["distance"]["value"]).first
              if addresses.present?
                addresses.update(address: a["address"],city: a["city"],
                  postal: a["postal"],
                  province: a["province"].upcase,
                  distance: distance["rows"][0]["elements"][1]["distance"]["value"] + distance["rows"][1]["elements"][0]["distance"]["value"]
                )
              else
                Address.create(idClient: params[:no], address: a["address"], city: a["city"], postal: a["postal"], province: a["province"].upcase,
                               idAddress: address.idAddress,
                               distance: distance["rows"][0]["elements"][1]["distance"]["value"] + distance["rows"][1]["elements"][0]["distance"]["value"])
              end
                if !params[:type].eql?("Individual")
                  busi = Business.where(idClient: params[:no]).first
                  if busi.present?
                    busi.update(name: params[:name],
                      description: params[:description],
                      contactPosition: params[:contactPosition],
                      pstTaxNo: params[:pstTaxNo],
                      gstTaxNo: params[:gstTaxNo])
                  else
                    busi = Business.create(idClient: params[:no],
                                    name: params[:name],
                                    description: params[:description],
                                    contactPosition: params[:contactPosition],
                                    pstTaxNo: params[:pstTaxNo],
                                    gstTaxNo: params[:gstTaxNo])
                  end
                  updatedClient = Customer.includes(:business, :address).where(idClient: params[:no]).first.to_json(:business, :address)
                  return render_json_response(updatedClient, :ok)
                else
                  if Contact.where(idBusiness: params[:no]).destroy_all
                    if Business.where(id: params[:no]).destroy_all
                      return render_json_response(clientNote, :ok)
                    end
                  end
                end
            else
              Address.where(idAddress: address["idAddress"]).update_all(idClient: params[:no], address: address["address"], city: address["city"], postal: address["postal"], province: address["province"].upcase)
              if params[:type].eql?("Individual")
                busi = Business.where(idClient:  params[:no]).first
                if busi.present?
                  busi.update(name: params[:name],
                              description: params[:description],
                              contactPosition: params[:contactPosition],
                              pstTaxNo: params[:pstTaxNo],
                              gstTaxNo: params[:gstTaxNo])
                else
                  busi = Business.create(name: params[:name],
                                         description: params[:description],
                                         contactPosition: params[:contactPosition],
                                         pstTaxNo: params[:pstTaxNo],
                                         gstTaxNo: params[:gstTaxNo])
                end
                updatedClient = Customer.includes(:address, :business).where(idClient: params[:no]).to_json(:address,:business)
                return render_json_response(updatedClient, :ok) if updatedClient
              else
                if Contact.where(idBusiness: params[:no]).destroy_all
                  if Business.where(id: params[:no]).destroy_all
                    updatedClient = Customer.includes(:address, :business).where(idClient: params[:no]).to_json(:address,:business)
                    return render_json_response(updatedClient, :ok) if updatedClient.present?
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def phones
    phones = Customer.select('idClient AS id, phone, cellPhone, secondaryPhone').where('phone LIKE ? OR cellPhone LIKE ? OR secondaryPhone LIKE ?', params['search'] + "%", params['search'] + "%", params['search'] + "%").limit(params['limit'].to_i).offset(params['offset'].to_i * params['limit'].to_i)
    return render_json_response(phones, :ok) if !phones.empty?
  end

  def client_phones
    client = Customer.includes(:address).where(phone: params[:phone]).first.to_json(:address)
    return render_json_response(client, :ok) if client.present?
    return render_json_response({:error => CLIENT_NOT_FOUND, :success => false}, :not_found)
  end

  def heardofus
    # clients.count({
    #         group: "Customer.idHeardOfUs",
    #         include: [{
    #             model: HeardOfUs, as: "heardofus"
    #         }],
    #         attributes: ["heardofus.type"]
    #     }).then(counters => {
    #         var lstData = [];
    #         var letters = '0123456789ABCDEF';
    #         var color = "";
    #         counters.forEach(counter => {
    #             color = "#";
    #             for (var i = 0; i < 6; i++) {
    #                 color += letters[Math.floor(Math.random() * 16)];
    #             }
    #             lstData.push({
    #                 label: counter.type,
    #                 data: counter.count,
    #                 color: color
    #             })
    #         });
    #         res.json(lstData);
    #     });

    count = Customer.joins(:heardofus).select("heardsofus.type").group("idHeardOfUs")
  end

  def postal
    addresses = Address.select('idAddress AS id, idClient, address, city, province, distance, postal').where('postal LIKE ? and idClient = ?', params[:search], params[:customer_id])
    if addresses
      return render_json_response(addresses, :ok)
    end
  end
	
  private 
  def check_params
    !params[:firstName] || !params[:lastName] || !params[:email] || !params[:type] || !params[:address] || !params[:city] || 
      !params[:postal] || !params[:province] || !params[:phoneNumber] || !params[:grade] || !params[:note] || !params[:heardOfUs]
  end

  def required_params
    !params[:type].eql?("Individual") && (!params[:name] || !params[:description] || !params[:contactPosition] || !params[:pstTaxNo] || !params[:gstTaxNo])
  end

  def get_address(formatted_address)
    twoAddress = "7628 Flewellyn Rd Stittsville, ON, K2S 1B6|" + formatted_address;
    url = "https://maps.googleapis.com/maps/api/distancematrix/json?key=#{process.env.GOOGLE_MAP_TOKEN}&origins=#{twoAddress}&destinations=#{twoAddress}"
    response = HTTParty.get(url)
    response.body
  end

  def check_address(distance)
    distance["rows"] && distance["rows"].length == 2 && distance["rows"][0]["elements"] && distance["rows"][0]["elements"][1]["status"] == "OK"
  end
end
