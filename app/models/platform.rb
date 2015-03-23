class Platform
  include Mongoid::Document

  has_many :projects

  field :name, type: String
  field :code, type: String
end
