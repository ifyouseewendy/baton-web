class Project
  include Mongoid::Document

  belongs_to :platform

  has_many :products
  has_many :orders

  field :name, type: String
end
