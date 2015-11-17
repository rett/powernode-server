Sidekiq.configure_server do |config|
  config.redis = { url: Powernode.config.redis_server }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Powernode.config.redis_server }
end

class Sidekiq::Extensions::DelayedMailer
  sidekiq_options(queue: Powernode.config.sidekiq_queue,
                  retry: Powernode.config.sidekiq_job_retries,
                  retries: Powernode.config.sidekiq_job_retries)
end
