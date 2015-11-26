Navigasmic.setup do |config|
  config.builder NavBuilder do |builder|
    builder.wrapper_class = 'sidebar-menu'
    builder.has_nested_class = 'treeview'
    builder.is_nested_class = 'treeview-menu'
  end
  config.semantic_navigation :navigation do |menu|
    menu.item 'NAVIGATION', class: 'header'
    menu.item 'Account', '#', icon: 'building', hidden_unless: proc { user_signed_in? && can?(:index, Account) } do
      menu.item 'My Account', proc { @current_account }, icon: 'home', highlights_on: proc { [account_path(@current_account),
                                                                                              edit_account_path(@current_account)] },
                hidden_unless: proc { can?(:show, @current_account) }
      menu.item 'Accounts', controller: '/accounts', icon: 'briefcase',
                highlights_on: proc { controller.request.path =~ /^\/accounts.*/ && @account != @current_account },
                hidden_unless: proc { can?(:manage, Account) || (can?(:index, Account) || @current_user.accounts.size > 0) }
      menu.item 'Users', icon: 'users', controller: '/users', hidden_unless: proc { can?(:index, User) }
      menu.item 'Invitations', controller: '/invitations', icon: 'mail-forward', hidden_unless: proc { can?(:index, Invitation) }
    end
    menu.item 'Site', '#', icon: 'map-o', hidden_unless: proc { user_signed_in? && can?(:index, Page) } do
      menu.item 'Pages', controller: '/pages', icon: 'book', hidden_unless: proc { can?(:index, Page) }
      menu.item 'Plans', controller: '/plans', icon: 'money', hidden_unless: proc { can?(:index, Plan) }
    end
    menu.item 'Node', '#', icon: 'server', hidden_unless: proc { user_signed_in? && can?(:index, Node)} do
      menu.item 'Agents', controller: '/agents', icon: 'user-secret', hidden_unless: proc { can?(:index, Agent) }
      menu.item 'Architectures', controller: '/node_architectures', icon: 'cog', hidden_unless: proc { can?(:index, NodeArchitecture) }
      menu.item 'Copy Paths', controller: '/node_module_copy_paths', icon: 'share-square-o', hidden_unless: proc { can?(:index, NodeModuleCopyPath) }
      menu.item 'Modules', controller: '/node_modules', icon: 'sitemap', hidden_unless: proc { can?(:index, NodeModule) }
      menu.item 'Module Categories', controller: '/node_module_categories', icon: 'folder-open-o', hidden_unless: proc { can?(:index, NodeModuleCategory) }
      menu.item 'Mount Points', controller: '/node_mount_points', icon: 'download', hidden_unless: proc { can?(:index, NodeMountPoint) }
      menu.item 'Nodes', controller: '/nodes', icon: 'laptop', hidden_unless: proc { can?(:index, Node) }, highlights_on: [{controller: 'nodes'}, controller: 'node_instances']
      menu.item 'Templates', controller: '/node_templates', icon: 'cubes', hidden_unless: proc { can?(:index, NodeTemplate) }
      menu.item 'Platforms', controller: '/node_platforms', icon: 'cube', hidden_unless: proc { can?(:index, NodePlatform) }
      menu.item 'Puppet Modules', controller: '/puppet_modules', icon: 'wrench', hidden_unless: proc { can?(:index, PuppetModule) }
      menu.item 'Scripts', controller: '/node_scripts', icon: 'file-text-o', hidden_unless: proc { can?(:index, NodeScript) }
    end
    menu.item 'Provider', '#', icon: 'cloud', hidden_unless: proc { user_signed_in? && can?(:index, ProviderConnection)} do
      menu.item 'Availability Zones', controller: '/provider_availability_zones', icon: 'globe', hidden_unless: proc { can?(:index, ProviderAvailabilityZone) }
      menu.item 'Connections', controller: '/provider_connections', icon: 'plug', hidden_unless: proc { can?(:index, ProviderConnection) }
      menu.item 'Instance Types', controller: '/provider_instance_types', icon: 'sliders', hidden_unless: proc { can?(:index, ProviderInstanceType) }
      menu.item 'Networks', controller: '/provider_networks', icon: 'sitemap', hidden_unless: proc { can?(:index, ProviderNetwork) }
      menu.item 'Subnets', controller: '/provider_network_subnets', icon: 'share-alt', hidden_unless: proc { can?(:index, ProviderNetworkSubnet) }
      menu.item 'Providers', controller: '/providers', icon: 'cloud', hidden_unless: proc { can?(:index, Provider) }
      menu.item 'Regions', controller: '/provider_regions', icon: 'map-signs', hidden_unless: proc { can?(:index, ProviderRegion) }
      menu.item 'Volumes', controller: '/provider_volumes', icon: 'hdd-o', hidden_unless: proc { can?(:index, ProviderVolume) }
      menu.item 'Volume Types', controller: '/provider_volume_types', icon: 'database', hidden_unless: proc { can?(:index, ProviderVolumeType) }
    end
  end
end
