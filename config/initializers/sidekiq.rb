redis_url = "redis://#{ENV.fetch('REDIS_HOST', 'localhost')}/:#{ENV.fetch('REDIS_PORT', '6379')}/#{ENV.fetch('REDIS_DB', '0')}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
