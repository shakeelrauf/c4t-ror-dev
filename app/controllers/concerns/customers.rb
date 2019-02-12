module Customers
  def get_heard_of_us
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
    last_data
  end

  def create_customer(params, current_user)
      heardofus = Heardofus.find_or_create_by(type: params[:heardOfUs])
      if heardofus.present?
        if Customer.phone_already_present?(params[:phoneNumber])
          client = Customer.find_or_initialize_by(phone: Validations.remove_dashes_from_phone(params[:phoneNumber]), cellPhone: Validations.remove_dashes_from_phone(params[:phoneNumber]), secondaryPhone: Validations.remove_dashes_from_phone(params[:phoneNumber]))
          if client.new_record?
            client = client_data(client, heardofus)
            params[:addresses].each do |a|
              if a.present?
                client_address(a, client)
              end
            end
            if !params[:type].eql?("Individual")
              busi = non_individual_business(client)
              if busi.save
                create_contacts(params, busi)
              end
            end
          else
            client = false
          end
        else
          client = false
        end
      end
    client
  end

  def client_data(client, heardofus)
    customDollarCar = 0
    customDollarSteel = 0
    customPercCar = 0
    customPercSteel = 0
    if current_user.present? && current_user.roles.downcase.eql?("admin")
      customDollarCar = params[:customDollarCar] if params[:customDollarCar]
      customDollarSteel = params[:customDollarSteel] if params[:customDollarSteel]
      customPercCar = params[:customPercCar] if params[:customPercCar]
      customPercSteel = params[:customPercSteel] if params[:customPercSteel]
    end
    client.idHeardOfUs = heardofus.idHeardOfUs
    client.firstName= params[:firstName]
    client.lastName = params[:lastName]
    client.email= params[:email]
    client.type = params[:type]
    client.extension = params[:extension]
    client.phone = Validations.remove_dashes_from_phone(params[:phoneNumber])
    client.cellPhone = Validations.remove_dashes_from_phone(params[:phoneNumber2])
    client.secondaryPhone = Validations.remove_dashes_from_phone(params[:phoneNumber3])
    client.note = params[:note]
    client.grade = params[:grade]
    client.customDollarCar = customDollarCar
    client.customDollarSteel = customDollarSteel
    client.customPercCar = customPercCar
    client.customPercSteel = customPercSteel
    client.save!
    client
  end

  def client_address(a, client)
    a = a.as_json
    prvc = a["province"].present? ? a["province"].upcase : a["province"]
    newAddress = client.address.new( address: a["address"],
                                      city: a["city"],
                                      postal: a["postal"],
                                      province: prvc)
    distance = JSON.parse(get_distance(newAddress))
    newAddress.distance = (distance["rows"][0]["elements"][0]["distance"]["value"] + distance["rows"][0]["elements"][0]["distance"]["value"])
    newAddress.save!
  end

  def non_individual_business(client)
    busi = client.build_business({
      name: params[:name],
      description: params[:description],
      contactPosition: params[:contactPosition],
      pstTaxNo: params[:pstTaxNo],
      gstTaxNo: params[:gstTaxNo],
      usersFlatFee: params[:usersFlatFee]})
    busi
  end

  def update_customer(params, current_user, id)
    response = false
    clientNote = Customer.where(idClient: id).first
    if clientNote.present?
      response = true
      heardofus = Heardofus.find_or_create_by(type: params[:heardOfUs])
      client_data(clientNote, heardofus)
      params[:addresses].each do |a|
        find_address(a, id)
      end
      if !params[:type].eql?("Individual")
        busi = Business.where(idClient: id).first
        busi = business_type(busi, id)
        busi.contacts.destroy_all
        create_contacts(params, busi)
      else
        Contact.where(idBusiness: id).destroy_all
      end
      response
    end
  end

  def business_type(busi, id)
    if busi.present?
      update_business(busi)
    else
      busi = create_business(id)
    end
    busi
  end

  def update_business(busi)
    busi.update(  name: params[:name],
                  description: params[:description],
                  contactPosition: params[:contactPosition],
                  pstTaxNo: params[:pstTaxNo],
                  gstTaxNo: params[:gstTaxNo],
                  usersFlatFee: params[:usersFlatFee])
  end

  def find_address(a, id)
    a = a.as_json
    prv = a["province"].present? ? a["province"].upcase : a["province"]
    if a["idAddress"].present?
      addresses = Address.where(idAddress: a["idAddress"]).first
    else
      addresses = Address.where(  idClient: id,
                                  address: a["address"],
                                  city: a["city"],
                                  postal: a["postal"],
                                  province: prv,
                                  distance: 361715).first
    end
    update_address(addresses, id, prv, a)
  end

  def create_business(id)
    busi = Business.create( idClient: id,
                            name: params[:name],
                            description: params[:description],
                            contactPosition: params[:contactPosition],
                            pstTaxNo: params[:pstTaxNo],
                            gstTaxNo: params[:gstTaxNo],
                            usersFlatFee: params[:usersFlatFee])
    busi
  end

  def update_address(addresses, id, prv, a)
    if addresses.present?
      addresses.update(address: a["address"],city: a["city"],
        postal: a["postal"],
        province: a["province"].upcase,
        distance: 361715
      )
    elsif a.present?
      Address.create( idClient: id,
                      address: a["address"],
                      city: a["city"],
                      postal: a["postal"],
                      province: prv,distance: 361715)
    end
  end


  def create_contacts(params, busi)
    unless params[:contacts].include?("")
      params[:contacts].each do |contact|
        contact = contact.as_json
        cont = busi.contacts.new( firstName: contact["firstName"],
                                  lastName: contact["lastName"],
                                  paymentMethod: contact["paymentMethod"])
        cont.save!
      end
    end
  end

  def check_params
    !params[:firstName] || !params[:lastName] || !params[:email] || !params[:type] || !params[:phoneNumber] || !params[:grade] || !params[:note] || !params[:heardOfUs]
  end

  def required_params
    !params[:type].eql?("Individual") && (!params[:name] || !params[:description] || !params[:contactPosition] || !params[:pstTaxNo] || !params[:gstTaxNo] || !params[:usersFlatFee])
  end

end