class Api::V1::CustomerController < ApiController
	before_action :authenticate_user

  def create
    if !params[:firstName] || params[:lastName] == nil || params[:email] == nil || !params[:type] || !params[:address] || !params[:city] || 
      params[:postal] == nil || !params[:province] || !params[:phoneNumber] || params[:grade] == nil || params[:note] == nil || !params[:heardOfUs]
      render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    elsif !params[:type].eql?("Individual") && (!params[:name] || params[:description] == nil || !params[:contactPosition] || !params[:pstTaxNo] || !params[:gstTaxNo]) 
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

      heardofus = Heardofu.find_or_create_by(type: params[:heardOfUs])
      if heardofus.present?
        client = Customer.find_or_create_by(phone: params[:phoneNumber]) do |client|
          client.idHeardOfUs = heardofus.id,
          client.firstName = params[:firstName],
          client.lastName = params[:lastName],
          client.email = params[:email],
          client.type = params[:type],
          client.phone = params[:phoneNumber],
          client.extension = params[:extension],
          client.cellPhone = params[:phoneNumber2],
          client.secondaryPhone = params[:phoneNumber3],
          client.note = params[:note],
          client.grade = params[:grade],
          client.customDollarCar = customDollarCar,
          client.customDollarSteel = customDollarSteel,
          client.customPercCar = customPercCar,
          client.customPercSteel = customPercSteel
        end
        if client.present?
          params[:addresses].each do |a|
            puts "ADDRESS ADDING :: #{address.address}"
            address = client.address.create(
              address: a.address,
              city: a.city,
              postal: a.postal,
              province: a.province.upcase)
              # distance: Number(distance.rows[0].elements[1].distance.value) + Number(distance.rows[1].elements[0].distance.value))
            if address
              if !params[:company].eql("0")
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
              end
            end
          end
        end
      end
    end
  end

  def index
    puts "LIST OF Clients"
    offset = 0
    filter = "%"
    offset = params[:offset].to_i if params[:offset] && params[:offset].to_i
    filter = "%" + params[:filter] + "%" if params[:filter]
    lstClients = Customer.where("firstName LIKE ? or lastName LIKE ? or type LIKE ? or email LIKE ? or phone LIKE ? extension LIKE ? OR cellPhone LIKE ? or secondaryPhone LIKE ? OR grade LIKE ? or note LIKE ?", filter,filter,filter,filter,filter,filter,filter,filter,filter,filter).order("firstName ASC and LastName ASC").limit(30).offset(offset)
    if lstClients
      lst = [];
      lstClients.each do |client|
        addr = Address.where(idClient: client.id)
        if addr
          client.address = addr
          lst.push(client)
        end
      end
      render json: resource.to_json, include: "business,business.contact,heardofu" status: status, adapter: :json_api
    end
  end

  def show
    puts 'Edit Screen API'
    client = Customer.where(idClient: req.params.no)
    if client
      adresse = Address.where(idClient: client.id)
      client.address = adresse
      return render_json_response(client, :ok)
    else
      render_json_response({:error => CLIENT_NOT_FOUND, :success => false}, :not_found)
    end
  end

  def update
    if !params[:firstName] || params[:lastName] == nil || params[:email] == nil || !params[:type] || !params[:address] || !params[:city] || 
      params[:postal] == nil || !params[:province] || !params[:phoneNumber] || params[:grade] == nil || params[:note] == nil || !params[:heardOfUs]
      render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    elsif !params[:type].eql?("Individual") && (!params[:name] || params[:description] == nil || !params[:contactPosition] || !params[:pstTaxNo] || !params[:gstTaxNo]) 
      render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
    else
      clientNote = Customer.where(idClient: params[:no])
      if !clientNote
        render_json_response({:error => CLIENT_NOT_FOUND, :success => false}, :not_found)
      else
        puts "Role:---------#{current_user.roles}"
        #Not admin can't edit previous notes. He can only add after.

        nparams = params[:type].merge(clientNote.type + "<br>" + params[:type].gsub(clientNote.type, "")) if !current_user.roles.eql?("admin")
        nparams = params if current_user.roles.eql?("admin")

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

          heardofus = Heardofu.find_or_create_by(type: params[:heardOfUs])
          if heardofus.present?
            client = Customer.where(idClient: params[:no]).first
            client.update(idHeardOfUs: heardofus.id, firstName: params[:firstName], lastName: params[:lastName], email: params[:email],
              type: params[:type], phone: params[:phoneNumber], extension: params[:extension], cellPhone: params[:phoneNumber2], secondaryPhone: params[:phoneNumber3],
              note: params[:note], grade: params[:grade], customDollarCar: customDollarCar, customDollarSteel: customDollarSteel, customPercCar: customPercCar, customPercSteel: customPercSteel) if client.present
            if client.present?
              hasError = false
              params[:addresses].each do |a|
                if !hasError && !address.address || !address.city || !address.postal || !address.province
                  render_json_response({:error => REQUIRED_ATTRIBUTES, :success => false}, :bad_request)
                  hasError = true;
                  return if hasError
                end
              end

              params[:addresses].each do |a|
                if address.idAddress.eql?('')
                  updatedAddress = Address.find_or_initialize(idClient: params[:no],
                    address: address.address,
                    city: address.city,
                    postal: address.postal,
                    province: address.province.upcase,
                    # distance: Number(distance.rows[0].elements[1].distance.value) + Number(distance.rows[1].elements[0].distance.value)
                    ).where(idClient: params[:no], address: address.address, city: address.city, postal: address.postal, province: address.province.upcase,
                      idAddress: address.idAddress, 
                      # distance: Number(distance.rows[0].elements[1].distance.value) + Number(distance.rows[1].elements[0].distance.value)
                    )
                  if updatedAddress
                    if !params[:type].eql?("Individual")
                      busi = Business.find_or_initialize(
                        id: params[:no],
                        name: params[:name],
                        description: params[:description],
                        contactPosition: params[:contactPosition],
                        pstTaxNo: params[:pstTaxNo],
                        gstTaxNo: params[:gstTaxNo])
                      if busi.present?
                        updatedClient = Customer.where(idClient: params[:no])
                        if updatedClient
                          updatedClient.business = busi
                          updatedClient.address = updatedAddress
                          return render_json_response(updatedClient, :ok)
                        end
                      end
                    else
                      if Contact.where(idBusiness: params[:no]).destroy
                        if Business.where(id: params[:no]).destroy
                          updatedClient = Customer.find_by_id(params[:no]
                          if updatedClient
                            updatedClient.address = updatedAddress
                            return render_json_response(updatedClient, :ok)
                          end
                        end
                      end
                    end
                                
                  end
                else
                  updatedAddress = Address.update(idClient: params[:no], address: address.address, city: address.city, postal: address.postal, province: address.province.toUpperCase().where(idAddress: address.idAddress)
                  if params[:type].eql?("Individual")
                    busi = Business.find_or_initialize(
                      id: params[:no],
                      name: params[:name],
                      description: params[:description],
                      contactPosition: params[:contactPosition],
                      pstTaxNo: params[:pstTaxNo],
                      gstTaxNo: params[:gstTaxNo])
                    if busi
                      updatedClient = Customer.find_by_id(params[:no])
                      if updatedClient
                        updatedClient.business = busi
                        updatedClient.address = updatedAddress
                        return render_json_response(updatedClient, :ok)
                      end
                    else 
                      if Contact.where(idBusiness: params[:no]).destroy
                        if Business.where(id: params[:no])
                          updatedClient =  Customer.find_by_id(params[:no])
                          if updatedClient.present?
                            updatedClient.address = updatedAddress
                            return render_json_response(updatedClient, :ok)
                          end
                        end
                      end
                    end
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
    phones = Customer.select('idClient AS id, phone, cellPhone, secondaryPhone').where('phone LIKE ? OR cellPhone LIKE ?
        OR secondaryPhone LIKE ?', params['search'] + "%", params['search'] + "%", params['search'] + "%").limit(params['limit'].to_i).offset(params['offset'].to_i * params['limit'].to_i)
    if phones
      return render_json_response(phones, :ok)
    end
  end

  def client_phones
    client = Customer.where(phone: params[:phone])
    if client
      adresse = Address.where(idClient: client.id).first
      client.address = adresse
      return render_json_response(client, :ok)
    else
      render_json_response({:error => CLIENT_NOT_FOUND, :success => false}, :not_found)
    end
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
  end

  def postal
    query = request.query_parameters
    addresses = Address.select('idAddress AS id, idClient, address, city, province, distance, postal').where('postal LIKE ? and idClient = ?', query['search'], params[:customer_id])
    if addresses
      return render_json_response(add, :ok)
    end
  end
	
  private 
  def get_address(formatted_address)
    twoAddress = "7628 Flewellyn Rd Stittsville, ON, K2S 1B6|" + formatted_address;
    url = "https://maps.googleapis.com/maps/api/distancematrix/json?key=#{process.env.GOOGLE_MAP_TOKEN}&origins=#{twoAddress}&destinations=#{twoAddress}"
    response = HTTParty.get(url)
    response.body
  end
end
