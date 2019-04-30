SIDEKIQ_ENABLED =  ["true", "1"].include?(ENV["SIDEKIQ_ENABLED"])

if SIDEKIQ_ENABLED
  redis_url = "redis://#{ENV.fetch('REDIS_HOST', 'localhost')}/:6379/0"

  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end
end
