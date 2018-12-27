class Customer < ApplicationRecord
	self.table_name = "Clients"
	self.inheritance_column = :_type_disabled
	has_many :address, class_name: 'Address', inverse_of: :client, foreign_key: 'idClient'
	has_one :business, class_name: 'Business',inverse_of: :client ,foreign_key: 'idClient'
	belongs_to :heardofus, class_name: 'Headofus', foreign_key: 'idHeardOfUs'
	has_many :satisfactions, class_name: 'Satisfication', foreign_key: "idClient"

	def name
		return this.firstName + ' ' + this.lastName
	end

	# def self.customUpsert(options, row)
	# 	this.findOrCreate(options).spread((row, created) => {
 #        if (created) {
 #            next(created, row);
 #        } else {
 #            this.update(options.defaults, {
 #                where: options.where
 #            }).then(updated => {
 #                this.findById(row.id).then(r_client => {
 #                    next(created, r_client);
 #                })
 #            });
 #        }
 #    });
	# end

	def self.customUpsert(options,row)
		@custom = find_or_initialize_by(options)
		if @custom.new_record?
		  @custom.save!
		else
			where(options.where).update_all(options.defaults)
			@cutom = find_by_id(row.id)
		end
	end

end
