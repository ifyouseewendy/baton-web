class HourlyStat
  include Mongoid::Document

  belongs_to :project

  field :date,  type: String
  field :hour,  type: Integer
  field :count, type: Integer
end
