class CustomerSerializer < ActiveModel::Serializer
  attributes :idClient, :idHeardOfUs, :firstName, :lastName, :type, :email, :phone, :extension, :cellPhone, :secondaryPhone, :note, :grade, :customDollarCar, :customDollarSteel, :customPercCar, :customPercSteel
end
