ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'minitest/focus'
require 'mocha/mini_test'
require 'pry-byebug'

Dir[Rails.root.join('test/support/**/*.rb')].each { |file| require file }

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  include Rack::Test::Methods

end

