CarrierWave.configure do |config|
  config.storage = :file
  config.root = Rails.root.join('public')
  config.cache_dir = "tmp"
end
