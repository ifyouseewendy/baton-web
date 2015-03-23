class HourlyStat
  include Mongoid::Document

  field :date,  type: String
  field :hour,  type: Integer
  field :count, type: Integer
end
