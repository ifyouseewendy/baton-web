class Project
  include Mongoid::Document

  belongs_to :platform

  has_many :products
  has_many :orders
  has_many :hourly_stats

  field :name, type: String
end
