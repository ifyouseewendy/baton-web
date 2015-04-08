class Product
  include Mongoid::Document

  belongs_to :project

  has_many :orders

  field :code, type: String
  field :property_serial, type: Array, default: []
end
