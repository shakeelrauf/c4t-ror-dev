class ContactSerializer < ActiveModel::Serializer
  attributes :idContact, :idBusiness, :firstName, :lastName, :paymentMethod
end
