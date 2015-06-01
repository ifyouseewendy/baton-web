source 'https://ruby.taobao.org'

ruby '2.2.0'

gem 'rails', '4.2.0'
gem 'mongoid'
gem "mongoid-enum"

# Cron
gem 'whenever', :require => false

# Front End
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem "jquery-fileupload-rails"

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Static Page
gem 'high_voltage', '~> 2.3.0'

# Fonts
gem 'font-awesome-sass'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Server
gem 'thin'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Console
gem 'pry-rails'
gem 'pry-doc'
gem 'awesome_print'

# Command Line
gem 'thor'

# Parse XLSx
gem 'roo', '2.0.0beta1'
gem 'roo-xls'

# Encoding
gem 'charlock_holmes'

# SFTP
gem 'net-sftp'

# Uploading
gem 'carrierwave'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'

# Pinyin
gem 'chinese_pinyin'

group :development do
  gem 'quiet_assets'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem "pry-byebug"
end

group :test do
  gem 'fabrication'
  gem 'minitest-reporters'
  gem 'minitest-focus'
  gem 'mocha'
end
