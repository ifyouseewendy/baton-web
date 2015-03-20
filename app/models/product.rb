class Product
  include Mongoid::Document

  has_many :orders

  field :code, type: String
end
