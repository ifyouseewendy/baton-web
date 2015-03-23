class Order
  include Mongoid::Document

  belongs_to :user
  belongs_to :product
  belongs_to :project

  field :serial_number,     type: String
  field :generated_at,      type: DateTime
  field :user_share,        type: Integer
end
