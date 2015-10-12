Devise::Async.backend = :sidekiq
Devise::Async.queue = Powernode.config.sidekiq_queue
