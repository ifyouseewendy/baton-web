require 'test_helper'

class HourlyOrderTest < ActiveSupport::TestCase
  setup do
    @hourly_order = HourlyOrder.new('xiaojin')
    def @hourly_order.root_path
      File.join(Rails.root, "test/jobs/resources")
    end

    def Date.today
      Date.parse("2015-03-20")
    end
  end

  teardown do
    [User, Product, Order, Platform, HourlyStat].map{|m| m.delete_all}
  end

  test "stub" do
    puts @hourly_order.root_path
  end

  test "platform created" do
    assert_equal 'xiaojin', @hourly_order.platform.name
  end

  test "parse_and_create_from" do
    assert_difference "HourlyStat.where(date: Date.today.to_s).count", 2 do
      @hourly_order.check

      assert_equal 2, User.count
      u = User.where(name: 'wendi').first
      assert_equal '220302198811112222', u.id_card_number
      assert_equal '18612341234', u.mobile

      assert_equal 1, Product.count

      assert_equal 2, Order.count
      o = Order.where(serial_number: '000001').first
      assert_equal 'xiaojin',   o.platform.name
      assert_equal 'wendi',     o.user.name
      assert_equal '300180',    o.product.code
      assert_equal 200,         o.user_share
      assert_equal Date.today,  o.generated_at.to_date

      assert_equal 2, HourlyStat.where(date: Date.today).first.count
    end
  end
end
