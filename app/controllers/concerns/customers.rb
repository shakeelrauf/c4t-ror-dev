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
        client = Customer.find_or_initialize_by(phone: params[:phoneNumber])
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
    client.cellPhone = params[:phoneNumber2]
    client.secondaryPhone = params[:phoneNumber3]
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
    newAddress = client.address.new( address: a["address"],city: a["city"],postal: a["postal"],province: prvc)
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
      gstTaxNo: params[:gstTaxNo]})
    busi
  end

  def update_customer(params, current_user, id)
    response = false
    clientNote = Customer.where(idClient: id).first
    if !clientNote
      response = false
    else
      address = "address"

      if address.present?
        customDollarCar = 0
        customDollarSteel = 0
        customPercCar = 0
        customPercSteel = 0
        updatedClient = ""

        if current_user.present? && current_user.roles.downcase.eql?("admin")
          customDollarCar = params[:customDollarCar] if params[:customDollarCar]
          customDollarSteel = params[:customDollarSteel] if params[:customDollarSteel]
          customPercCar = params[:customPercCar] if params[:customPercCar]
          customPercSteel = params[:customPercSteel] if params[:customPercSteel]
        end

        heardofus = Heardofus.find_or_create_by(type: params[:heardOfUs])
        clientNote.update(idHeardOfUs: heardofus.id, firstName: params[:firstName], lastName: params[:lastName], email: params[:email],
            type: params[:type], phone: params[:phoneNumber], extension: params[:extension], cellPhone: params[:phoneNumber2], secondaryPhone: params[:phoneNumber3],
            note: params[:note], grade: params[:grade], customDollarCar: customDollarCar, customDollarSteel: customDollarSteel, customPercCar: customPercCar, customPercSteel: customPercSteel) if clientNote.present?
        params[:addresses].each do |a|
          if address
            a = a.as_json
            prv = a["province"].present? ? a["province"].upcase : a["province"]
            if a["idAddress"].present?
              addresses = Address.where(idAddress: a["idAddress"]).first
            else
              addresses = Address.where(idClient: id, address: a["address"], city: a["city"], postal: a["postal"], province: prv,distance: 361715).first
            end
            if addresses.present?
              addresses.update(address: a["address"],city: a["city"],
                postal: a["postal"],
                province: a["province"].upcase,
                distance: 361715
              )
            elsif a.present?
              Address.create(idClient: id, address: a["address"], city: a["city"], postal: a["postal"], province: prv,
                                             distance: 361715)
            end
              if !params[:type].eql?("Individual")
                busi = Business.where(idClient: id).first
                if busi.present?
                  busi.update(name: params[:name],
                    description: params[:description],
                    contactPosition: params[:contactPosition],
                    pstTaxNo: params[:pstTaxNo],
                    gstTaxNo: params[:gstTaxNo])
                else
                  busi = Business.create(idClient: id,
                                  name: params[:name],
                                  description: params[:description],
                                  contactPosition: params[:contactPosition],
                                  pstTaxNo: params[:pstTaxNo],
                                  gstTaxNo: params[:gstTaxNo])
                end
                busi.contacts.destroy_all
                create_contacts(params, busi)
                updatedClient = Customer.includes(:business, :address).where(idClient: id).first
              else
                Contact.where(idBusiness: id).destroy_all
              end
          else
            Address.where(idAddress: address["idAddress"]).update_all(idClient: id, address: address["address"], city: address["city"], postal: address["postal"], province: address["province"].upcase)
            if params[:type].eql?("Individual")
              busi = Business.where(idClient:  id).first
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
              busi.contacts.destroy_all
              create_contacts(params, busi)
              updatedClient = Customer.includes(:address, :business).where(idClient: id).to_json(:address,:business)
            else
              if Contact.where(idBusiness: id).destroy_all
                if Business.where(id: id).destroy_all
                  updatedClient = Customer.includes(:address, :business).where(idClient: id).to_json(:address,:business)
                end
              end
            end
          end
        end
        if updatedClient.present?
          response = updatedClient
        elsif clientNote.present?
          response = clientNote
        else
          response = false
        end
      end
    end
  end

  def create_contacts(params, busi)
    unless params[:contacts].include?("")
      params[:contacts].each do |contact|
        contact = contact.as_json
        cont = busi.contacts.new(firstName: contact["firstName"], lastName: contact["lastName"], paymentMethod: contact["paymentMethod"])
        cont.save!
      end
    end
  end

  def check_params
    !params[:firstName] || !params[:lastName] || !params[:email] || !params[:type] || !params[:phoneNumber] || !params[:grade] || !params[:note] || !params[:heardOfUs]
  end

  def required_params
    !params[:type].eql?("Individual") && (!params[:name] || !params[:description] || !params[:contactPosition] || !params[:pstTaxNo] || !params[:gstTaxNo])
  end

end