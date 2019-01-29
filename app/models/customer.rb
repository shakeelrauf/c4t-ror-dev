class Customer < ApplicationRecord
	self.table_name = "clients"
	self.inheritance_column = :_type_disabled
	has_many :address, class_name: 'Address', inverse_of: :client, foreign_key: 'idClient'
	has_one :business, class_name: 'Business',inverse_of: :client ,foreign_key: 'idClient'
	belongs_to :heardofus, class_name: 'Heardofus', foreign_key: 'idHeardOfUs'
	has_many :satisfactions, class_name: 'Satisfication', foreign_key: "idClient"
	has_many :quotes, class_name: 'Quote', foreign_key: 'idClient'

	def name
		return self.firstName + ' ' + self.lastName
	end

	def self.custom_upsert(options={},where={})
		@custom = where(where).first
		if @custom.present?
			@custom.update(options)
			@cutom = @cutom
		else
			@custom =  new(options.merge(where))
			@custom.attributes.each do |key, value|
				@custom[key] = "" if value.nil?
			end
			@custom.save!
		end
		@custom
	end

	class << self

		def form_body(params)
			{
			  "heardOfUs":      	params[:heardOfUs],
			  "phoneNumber":    	params[:phoneNumber],
			  "firstName":      	params[:firstName],
			  "lastName":       	params[:lastName],
			  "email":          	params[:email],
			  "type":           	params[:type],
			  "extension":      	params[:extension],
			  "phoneNumber2":   	params[:phoneNumber2],
			  "phoneNumber3":   	params[:phoneNumber3],
			  "note":           	params[:note],
			  "grade":          	params[:grade],
			  "address":        	params[:address],
			  "city":           	params[:city],
			  "province":       	params[:province],
			  "postal":         	params[:postal],
			  "customDollarCar":    params[:customDollarCar],
			  "customDollarSteel":  params[:customDollarSteel],
			  "customPercCar": 		params[:customPercCar],
			  "customPercSteel": 	params[:customPercSteel],
			  "addresses":      	address_data(params),
			  "contacts":       	contact_data(params)
			}.merge(company_data(params))
		end

		def address_data(params)
			addresses = []
			if params[:addresses].present?
			  p_key = params[:addresses]
			  p_key["address"].zip(p_key["city"],
			                       p_key["province"],
			                       p_key["postal"],
			                       p_key["idAddress"]).each do |adr, city, pro, pos, id|
			    addresses << {
			                    "address":   adr,
			                    "city":      city,
			                    "province":  pro,
			                    "postal":    pos,
			                    "idAddress": id
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

end
