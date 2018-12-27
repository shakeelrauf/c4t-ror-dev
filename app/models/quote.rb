class Quote < ApplicationRecord
	self.table_name = "Quotes"
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


	def self.customUpsert(options, row)
		
	end
end
