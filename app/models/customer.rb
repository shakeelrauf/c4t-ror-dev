class Customer < ApplicationRecord
	self.table_name = "Clients"
	self.inheritance_column = :_type_disabled
	has_many :address, class_name: 'Address', inverse_of: :client, foreign_key: 'idClient'
	has_one :business, class_name: 'Business',inverse_of: :client ,foreign_key: 'idClient'
	belongs_to :heardofus, class_name: 'Heardofus', foreign_key: 'idHeardOfUs'
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

	def self.customUpsert(options={},where={})
		@custom = where(where).first
		if @custom.present?
			@custom.update(options)
			@cutom = @cutom
		else
			@custom =  create(options.merge(where))
		end
		@custom
	end

end
