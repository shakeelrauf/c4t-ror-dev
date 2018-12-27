class BusinessSerializer < ActiveModel::Serializer
  attributes :idClient, :name, :description, :contactPosition, :pstTaxNo, :gstTaxNo
end
