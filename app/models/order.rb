class Order
  include Mongoid::Document

  belongs_to :user
  belongs_to :platform
  belongs_to :product

  field :serial_number,     type: String
  field :generated_at,      type: DateTime
  field :user_share,        type: Integer
end
