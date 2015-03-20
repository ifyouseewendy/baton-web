# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

xiaojin = Platform.create(
  name: 'xiaojin',
  code: 'AA'
)

wendi = User.create(
  name:             'Di Wen',
  gender:           1,
  mobile:           '13612341234',
  telephone:        '010-61106110',
  post_code:        '100083',
  address:          'Peony Garden',
  id_card_number:   '220302198811112222',
  id_card_address:  'Siping, Jilin'
)

product = Product.create(
  code: '300180'
)

order_1 = Order.create(
  user:           wendi,
  platform:       xiaojin,
  product:        product,
  serial_number:  '000001',
  generated_at:   Time.now,
  user_share:     100
)

order_2 = Order.create(
  user:           wendi,
  platform:       xiaojin,
  product:        product,
  serial_number:  '000002',
  generated_at:   Time.now,
  user_share:     200
)
