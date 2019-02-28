class TruckSerializer < ActiveModel::Serializer
  attributes :id, :name, :make, :model, :year, :flatbed, :flatbed_type, :car_capacity
end
