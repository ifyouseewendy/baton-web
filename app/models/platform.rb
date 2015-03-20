class Platform
  include Mongoid::Document

  has_many :orders

  field :name, type: String
  field :code, type: String
end
