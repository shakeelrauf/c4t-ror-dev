class Truck < ApplicationRecord

    validates_presence_of :name, :make, :model, :flatbed_type, :car_capacity, :weight_capacity

end
