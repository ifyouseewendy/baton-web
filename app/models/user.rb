class User
  include Mongoid::Document

  has_many :orders

  field :name,            type: String
  field :gender,          type: Integer # 1 for male, 2 for female
  field :mobile,          type: String
  field :telephone,       type: String
  field :post_code,       type: String
  field :address,         type: String
  field :id_card_number,  type: String
  field :id_card_address, type: String

end
