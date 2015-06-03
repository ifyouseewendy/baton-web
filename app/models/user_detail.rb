# Temp used in xiaojin tranfer stage. Record user owns product's amount.
class UserDetail
  include Mongoid::Document
  include Mongoid::Timestamps

  field :product_code,  type: String
  field :user_name,     type: String
  field :user_id_card,  type: String
  field :amount,        type: Integer # Xiaojin uses fen as the basic unit, that save 10000 for 100.00 yuan.

  private

    def to_s
      [product_code, user_name, user_id_card, amount].join(' - ')
    end
end
