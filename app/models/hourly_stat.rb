class HourlyStat
  include Mongoid::Document

  belongs_to :project

  field :date,        type: String
  field :hour,        type: Integer
  field :order_count, type: Integer
  field :share_count, type: Float
end
