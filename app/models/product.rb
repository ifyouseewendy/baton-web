class Product
  include Mongoid::Document

  belongs_to :project

  has_many :orders

  field :code, type: String
end
