Sidekiq.configure_server do |config|
  config.redis = { url: Powernode.config.redis_server,
                   namespace: Powernode.config.redis_namespace }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Powernode.config.redis_server,
                   namespace: Powernode.config.redis_namespace }
end

class Sidekiq::Extensions::DelayedMailer
  sidekiq_options(queue: Powernode.config.sidekiq_queue,
                  retry: Powernode.config.sidekiq_job_retries,
                  retries: Powernode.config.sidekiq_job_retries)
end
