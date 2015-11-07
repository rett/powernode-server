puts 'Loading seed data...'

if Plan.count == 0
  puts 'Creating plans...'
  plan_params = [
    { name: 'Tier 1 - Free',
      amount: 0,
      interval: 'month',
      interval_count: 1,
      user_limit: 1,
      node_limit: 1,
      instance_limit: 1,
      default_roles: %w[account_manager user_manager node_manager]
    }
  ]
  plan = Plan.create(plan_params).first
else
  plan = Plan.first
end

if User.count == 0
  puts 'Creating admin user...'
  user_params = {
    name: 'Admin User',
    email: Powernode.config.smtp_admin_email,
    locale: 'en',
    password: 'admin123',
    password_confirmation: 'admin123',
    plan_id: plan.id
  }
  user = User.new(user_params)
  user.roles = User::ROLES
  user.save
  user.confirm!
else
  user = user.first
end

account = user.account

if Agent.count == 0
  puts 'Creating agent...'
  agent_params = [
    { account: account,
      name: 'Agent',
      description: 'Primary Agent',
      key: 'agent123',
      key_confirmation: 'agent123',
      enabled: true,
      primary: true,
      public: true
    }
  ]
  agent = Agent.create(agent_params).first
  account.agent = agent
  account.save
end

if ProviderInstanceType.count == 0
  puts 'Creating node instance types...'
  provider_instance_type_params = [
    { account: account,
      name: 'm1.tiny',
      description: 'M1 Tiny'
    },
    { account: account,
      name: 'm1.small',
      description: 'M1 Small'
    }
  ]
  provider_instance_types = ProviderInstanceType.create(provider_instance_type_params)
else
  provider_instance_types = ProviderInstanceType.all
end

if Provider.count == 0
  puts 'Creating providers...'
  provider_params = [
    { name: 'aws',
      description: 'Amazon Web Services',
      enabled: true,
      public: true
    }
  ]
  provider = Provider.create(provider_params).first
else
  provider = Provider.first
end

if ProviderRegion.count == 0
  puts 'Creating provider regions...'
  provider_region_params = [
    { account: account,
      name: 'us-east-1',
      description: 'Amazon Web Services East',
      provider_id: provider.id,
      endpoint_url: 'https://ec2.us-east-1.amazonaws.com/',
      enabled: true,
      public: true
    }
  ]
  provider_region = ProviderRegion.create(provider_region_params).first
  provider_region.provider_instance_types << provider_instance_types
end

if Page.count == 0
  puts 'Creating welcome page...'
  page_params = [
    { name: 'welcome',
      title: 'Welcome to Node Alchemy',
      content: 'Welcome',
      enabled: true,
      public: true
    },
    { name: 'management',
      title: 'Node Alchemy Management',
      content: 'Welcome to the management section of Node Alchemy',
      enabled: true,
      public: true
    },
    { name: 'subscription',
      title: 'Subscription Management',
      content: 'Subscription management section of Node Alchemy',
      enabled: true,
      public: true
    },
    { name: 'account',
      title: 'Account Management',
      content: 'Account management section of Node Alchemy',
      enabled: true,
      public: true
    },
    {
      name: 'thanks',
      title: 'Thanks for subscribing',
      content: 'Thank you for subscribing!  You can log in after confirming your email address.',
      enabled: true,
      public: true
    },
    {
      name: 'cancel',
      title: 'Cancel account',
      content: 'You are about to cancel your account.',
      enabled: true,
      public: true
    },
    {
      name: 'canceled',
      title: 'Account canceled',
      content: 'We are sorry to see you go, your account has been cancelled.',
      enabled: true,
      public: true
    }
  ]
  Page.create(page_params)
end

if NodeScript.count == 0
  puts 'Creating node scripts...'
  node_script_params = [
    {
      account: account,
      name: 'apt_build',
      description: 'APT build script',
      variety: 'build',
      enabled: true,
      public: true
    },
    { account: account,
      name: 'basic_mount',
      description: 'Basic mount script',
      variety: 'mount',
      enabled: true,
      public: true
    },
    { account: account,
      name: 'ipn_initialize',
      description: 'IPN initialization script',
      variety: 'init',
      enabled: true,
      public: true
    },
    { account: account,
      name: 'ipn_functions',
      description: 'IPN function library',
      variety: 'utility',
      enabled: true,
      public: true
    },
    { account: account,
      name: 'ipn',
      description: 'IPN command',
      variety: 'utility',
      enabled: true,
      public: true
    },
    { account: account,
      name: 'sync_instance',
      description: 'Synchronize instance',
      variety: 'utility',
      enabled: true,
      public: true
    }
  ]
  NodeScript.create(node_script_params)
end

if ProviderVolumeType.count == 0
  puts 'Creating volume types...'
  provider_volume_type_params = [
    { account: account,
      mount_script: NodeScript.mount_variety.first,
      name: 'ebs',
      description: 'Enterprise Block Storage',
      enabled: true,
      public: true
    }
  ]
  ProviderVolumeType.create(provider_volume_type_params)
end

puts 'Finished.'
