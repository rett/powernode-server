class Ability
  include CanCan::Ability

  def initialize(user: nil, account: nil, admin_view: false, agent: nil)
    user      = agent.account.owner if agent
    user    ||= User.new
    account ||= user.account

    #
    # Page permissions
    #
    can [:resource, :show],                               [Page],                     public: true, enabled: true
    if user.has_role?(:page_manager)
      can [:create, :index, :show, :update, :destroy],    [Page],                     account_id: account.id
    end

    if account.new_record?
      #
      # Sign-up permissions
      #
      can [:new, :create, :plans, :plan],                 [Account]
    else
      #
      # Account Manager permissions
      #
      can [:index], [Account] if user.accounts.size > 0
      if user.has_role?(:account_manager)
        can [:billing, :cancel, :index, :show],           [Account],                  id: account.id
        can [:delegation, :select],                       [Account],                  id: account.id
        can [:index, :show, :select, :plan, :update],     [Account],                  id: user.account.id
        can [:create],                                    [User],                     account_id: user.account.id
        can [:create, :destroy, :index, :show, :update],  [AccountDelegation],        account_id: user.account.id
        user.account_delegations.enabled.each do |delegation|
          can [:select, :index, :show],                   [Account],                  id: delegation.account_id
        end
      end

      #
      # Agent Manager permissions
      #
      if user.has_role?(:agent_manager)
        can [:create, :index, :show, :update, :destroy],  [Agent],                    account_id: account.id
      end

      #
      # Invitation permissions
      #
      if user.has_role?(:invitation_manager)
        can [:create, :index, :show, :update, :destroy],  [Invitation],               account_id: user.account.id
      end

      #
      # User Manager permissions
      #
      if user.has_role?(:user_manager)
        can [:create, :index, :show, :update, :destroy],  [User],                     account_id: user.account.id
      end

      #
      # Node Manager permissions
      #
      if user.has_role?(:node_manager)
        can [:download_image, :update_provider_items],    [Node],                     account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [Node],                     account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [NodeInstance],             node: { account_id: account.id }
        can [:select_provider_instance_types],            [Node],                     account_id: account.id
        can [:control_node],                              [Node],                     account_id: account.id
        can [:select_provider_instance_types],            [Node],                     account_id: account.id
        can [:create, :index, :retry, :show, :update, :destroy],  [Operation],        account_id: account.id
        user.account_delegations.enabled.each do |delegation|
          delegation.account.nodes.each { |node| can [:control_node], node }
        end
      end

      #
      # Node Module Manager permissions
      #
      if user.has_role?(:node_module_manager)
        can [:dependency_tree, :update_platform_items],   [NodeModule],               account_id: account.id
        can [:create],                                    [NodeModuleDependency]
        can [:create, :index, :show, :update, :destroy],  [NodeModule],               account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [NodeModuleCategory],       account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [NodeModuleCopyPath],       account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [NodeMountPoint],           account_id: account.id
      end

      #
      # Node Platform Manager permissions
      #
      if user.has_role?(:node_platform_manager)
        can [:create, :index, :show, :update, :destroy],  [NodePlatform],             account_id: account.id
      end

      #
      # Node Script permissions
      #
      if user.has_role?(:node_script_manager)
        can [:create, :index, :show, :update, :destroy],  [NodeScript],               account_id: account.id
      end

      #
      # Node Template Manager permissions
      #
      if user.has_role?(:node_template_manager)
        can [:update_platform_items],                     [NodeTemplate],             account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [NodeTemplate],             account_id: account.id
      end

      #
      # Operation permissions
      #
      if user.has_role?(:account_manager)
        can [:control, :reschedule, :index, :show, :destroy],  [Operation],           account_id: account.id
      end

      #
      # Provider Manager permissions
      #
      if user.has_role?(:provider_manager)
        can [:create, :index, :show, :update, :destroy],  [Provider],                 account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [ProviderAvailabilityZone], account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [ProviderRegion],           account_id: account.id
      end

      #
      # Plan Manager permissions
      #
      if user.has_role?(:plan_manager)
        can [:create, :index, :show, :update, :destroy],  [Plan],                     account_id: account.id
      end

      #
      # Provider Connection Manager permissions
      #
      if user.has_role?(:provider_connection_manager)
        can [:create, :index, :show, :update, :destroy],  [ProviderConnection],       account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [ProviderInstanceType],     account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [ProviderNetwork],          account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [ProviderNetworkSubnet],    account_id: account.id
        can [:create, :index, :show, :update, :destroy],  [ProviderVolume],           account_id: account.id
        can [:update_provider_items],                     [ProviderVolume],           account_id: account.id
      end

      #
      # Puppet permissions
      #
      if user.has_role?(:puppet_manager)
        can [:create, :index, :show, :update, :destroy],  [PuppetModule],             account_id: account.id
      end

      #
      # Usage permissions
      #
      can [:use], [Agent],                    enabled: true, public: true
      can [:use], [Agent],                    enabled: true, account_id: account.id
      can [:use], [NodeArchitecture],         enabled: true, public: true
      can [:use], [NodeArchitecture],         enabled: true, account_id: account.id
      can [:use], [NodeModule],               enabled: true, public: true
      can [:use], [NodeModule],               enabled: true, account_id: account.id
      can [:use], [NodeModuleCategory],       enabled: true, public: true
      can [:use], [NodeModuleCategory],       enabled: true, account_id: account.id
      can [:use], [NodeModuleCopyPath],       enabled: true, public: true
      can [:use], [NodeModuleCopyPath],       enabled: true, account_id: account.id
      can [:use], [NodeMountPoint],           enabled: true, public: true
      can [:use], [NodeMountPoint],           enabled: true, account_id: account.id
      can [:use], [NodePlatform],             enabled: true, public: true
      can [:use], [NodePlatform],             enabled: true, account_id: account.id
      can [:use], [NodeTemplate],             enabled: true, public: true
      can [:use], [NodeTemplate],             enabled: true, account_id: account.id
      can [:use], [NodeScript],               enabled: true, public: true
      can [:use], [NodeScript],               enabled: true, account_id: account.id
      can [:use], [Plan],                     enabled: true, public: true
      can [:use], [Plan],                     enabled: true, account_id: account.id
      can [:use], [Provider],                 enabled: true, public: true
      can [:use], [Provider],                 enabled: true, account_id: account.id
      can [:use], [ProviderAvailabilityZone], enabled: true, public: true
      can [:use], [ProviderConnection],       enabled: true, account_id: account.id
      can [:use], [ProviderRegion],           enabled: true, public: true
      can [:use], [ProviderRegion],           enabled: true, account_id: account.id
      can [:use], [ProviderInstanceType],     enabled: true, public: true
      can [:use], [ProviderInstanceType],     enabled: true, account_id: account.id
      can [:use], [ProviderNetwork],          enabled: true, account_id: account.id
      can [:use], [ProviderNetworkSubnet],    enabled: true, account_id: account.id
      can [:use], [ProviderVolume],           enabled: true, account_id: account.id
      can [:use], [ProviderVolumeType],       enabled: true, public: true
      can [:use], [ProviderVolumeMember],     enabled: true, account_id: account.id
      can [:use], [PuppetModule],             enabled: true, public: true
      can [:use], [PuppetModule],             enabled: true, account_id: account.id

      #
      # Publisher permissions
      #
      can [:publish], [NodeModule],   account_id: account.id if user.has_role?(:node_module_publisher)
      can [:publish], [NodePlatform], account_id: account.id if user.has_role?(:node_platform_publisher)
      can [:publish], [NodeScript],   account_id: account.id if user.has_role?(:node_script_publisher)
      can [:publish], [NodeTemplate], account_id: account.id if user.has_role?(:node_template_publisher)
      can [:publish], [Page],         account_id: account.id if user.has_role?(:page_publisher)
      can [:publish], [PuppetModule], account_id: account.id if user.has_role?(:puppet_publisher)

      #
      # Admin Permissions
      #
      if agent || admin_view
        can [:manage], [Invitation]             if user.has_role?(:invitation_admin)
        can [:manage], [Account]                if user.has_role?(:account_admin)
        can [:manage], [User]                   if user.has_role?(:account_admin)
        can [:manage], [Plan]                   if user.has_role?(:account_admin)
        can [:manage], [Operation]              if user.has_role?(:account_admin)
        can [:manage], [Agent]                  if user.has_role?(:agent_admin)
        can [:manage], [User]                   if user.has_role?(:user_admin)
        can [:manage], [Node]                   if user.has_role?(:node_admin)
        can [:manage], [NodeInstance]           if user.has_role?(:node_admin)
        can [:manage], [NodeMountPoint]         if user.has_role?(:node_admin)
        can [:manage], [NodeModule]             if user.has_role?(:node_module_admin)
        can [:manage], [NodeModuleCategory]     if user.has_role?(:node_module_admin)
        can [:manage], [NodeModuleCopyPath]     if user.has_role?(:node_module_admin)
        can [:manage], [NodeModuleDependency]   if user.has_role?(:node_module_admin)
        can [:manage], [NodePlatform]           if user.has_role?(:node_platform_admin)
        can [:manage], [NodeArchitecture]       if user.has_role?(:node_platform_admin)
        can [:manage], [NodeScript]             if user.has_role?(:node_script_admin)
        can [:manage], [NodeTemplate]           if user.has_role?(:node_template_admin)
        can [:manage], [Page]                   if user.has_role?(:page_admin)
        can [:manage], [Plan]                   if user.has_role?(:plan_admin)
        can [:manage], [Provider]               if user.has_role?(:provider_admin)
        can [:manage], [ProviderRegion]         if user.has_role?(:provider_admin)
        can [:manage], [ProviderNetwork]        if user.has_role?(:provider_admin)
        can [:manage], [ProviderInstanceType]   if user.has_role?(:provider_admin)
        can [:manage], [ProviderNetworkSubnet]  if user.has_role?(:provider_admin)
        can [:manage], [ProviderVolume]         if user.has_role?(:provider_admin)
        can [:manage], [ProviderVolumeMember]   if user.has_role?(:provider_admin)
        can [:manage], [ProviderVolumeType]     if user.has_role?(:provider_admin)
        can [:manage], [PuppetModule]           if user.has_role?(:puppet_admin)
        can [:manage], [PuppetResource]         if user.has_role?(:puppet_admin)
        can [:manage], :all                     if user.has_role?(:global_admin)
      end
    end

    #
    # Global Restrictions
    #
    cannot [:create],  [Account] if user.persisted?
    cannot [:destroy], [Account]
    cannot [:destroy], [User], id: user.id
  end
end
