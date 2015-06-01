# Temp used in xiaojin tranfer stage. Record user owns product's amount.
class UserDetail
  include Mongoid::Document
  include Mongoid::Timestamps

  field :product_code,  type: String
  field :user_name,     type: String
  field :user_id_card,  type: String
  field :amount,        type: Float

end