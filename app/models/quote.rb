class Quote < ApplicationRecord
	self.table_name = "Quotes"
	has_many :quote_car, class_name: 'QuoteCar', foreign_key: 'idQuote'
	belongs_to :dispatcher, class_name: 'User',     foreign_key: 'idUser'
	belongs_to :customer,   class_name: 'Customer', foreign_key: 'idClient', optional: true
	belongs_to :status,    class_name: 'Status',   foreign_key: 'idStatus'

	def self.custom_upsert(options, where)
		@quote = where(where).first
		if @quote.present?
			@quote.update(options)
		else
			@quote = new(options.merge(where))
			@quote.attributes.each do |key, value|
				@quote[key] = "" if value.nil?
			end
		end
		@quote.save!
		return @quote
	end
end
