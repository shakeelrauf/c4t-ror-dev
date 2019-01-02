class Quote < ApplicationRecord
	self.table_name = "Quotes"
	has_many :quote_car, class_name: 'QuoteCar'
	belongs_to :dispatcher, class_name: 'User',     foreign_key: 'idUser'
	belongs_to :customer,   class_name: 'Customer', foreign_key: 'idClient'
	belongs_to :status,    class_name: 'Status',   foreign_key: 'idStatus'




# quotes.customUpsert = function (options, next) {
#     var onUpdate = options.defaults;
#     options.defaults = Object.assign(options.defaults, options.oncreate);
#     delete options.oncreate;
#     this.findOrCreate(options).spread((row, created) => {
#         if (created) {
#             next(created, row);
#         } else {
#             options.defaults = onUpdate;
#             this.update(options.defaults, {
#                 where: options.where
#             }).then(updated => {
#                 this.findById(row.id).then(r_client => {
#                     next(created, r_client);
#                 })
#             });
#         }
#     });
# };


	def self.customUpsert(options, where)
		@qoute = where(where).first
		if @qoute.present?
			@quote.update(options)
		else
			@quote = create(options.merge(where))
		end
		return @quote
	end
end
