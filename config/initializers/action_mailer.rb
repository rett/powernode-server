smtp_settings = {}
smtp_settings[:address] = Powernode.config.smtp_server
smtp_settings[:delivery_method] = Powernode.config.smtp_method
smtp_settings[:port] = Powernode.config.smtp_port
smtp_settings[:domain] = Powernode.config.smtp_domain
smtp_settings[:user_name] = Powernode.config.smtp_user_name
smtp_settings[:password] = Powernode.config.smtp_password
smtp_settings[:authentication] = Powernode.config.smtp_authentication
smtp_settings[:enable_starttls_auto] = Powernode.config.smtp_enable_starttls_auto

ActionMailer::Base.smtp_settings = smtp_settings
ActionMailer::Base.default_url_options = { host: Powernode.config.server_hostname }
