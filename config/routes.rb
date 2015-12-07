Powernode::Application.routes.draw do
  #
  # Root Route
  #
  root to: 'pages#show', id: 'welcome'

  #
  # Sidekiq Web Interface
  #
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.roles.include?(:global_admin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  #
  # Stripe Event routes
  #
  mount StripeEvent::Engine => '/stripe'

  #
  # Account Routes
  #
  resources :accounts do
    member do
      match 'billing', via: [:get, :post]
      match 'cancel', via: [:get, :post]
      match 'delegation', via: [:delete, :post]
      match 'plans', via: [:get]
      match 'select', via: [:get]
    end
  end

  #
  # Agent Routes
  #
  resources :agents

  #
  # User Routes
  #
  devise_for :users, controllers: { registrations: 'registrations' }, path: :auth
  devise_scope :user do
    get 'auth/plans' => 'registrations#plans'
  end
  resources :users

  #
  # Subscription Plan Routes
  #
  resources :plans

  #
  # Invitation Routes
  #
  resources :invitations

  #
  # Page Routes
  #
  resources :pages
  get '/resource/:page_id/:name(/:style)' => 'pages#resource', as: :resource

  #
  # Node Management Routes
  #
  resources :nodes do
    member do
      get 'node_instances'
      get '/image/:node_instance_id' => 'nodes#download_image', as: :download_image
      get '/iso/:node_instance_id' => 'nodes#download_iso', as: :download_iso
      match '/control' => 'nodes#control_node', via: [:get, :post], as: :control
    end
    get '/update_provider_items' => 'nodes#update_provider_items', on: :member
  end

  #
  # Node Architecture Routes
  #
  resources :node_architectures, path: 'architectures' do
    member do
      get :download_image
    end
  end

  #
  # Node Instance Routes
  #
  resources :node_instances, path: 'instances', only: [:edit, :show, :update]

  #
  # Node Module Category Routes
  #
  resources :node_module_categories, path: 'categories'

  #
  # Node Module Copy Path Routes
  #
  resources :node_module_copy_paths, path: 'copy_paths'

  #
  # Node Module Routes
  #
  resources :node_modules, path: 'modules' do
    member do
      get :dependency_tree
      get :download
    end
    get '/update_platform_items(/:node_platform_id)' => 'node_modules#update_platform_items', on: :collection
    get '/update_platform_items(/:node_platform_id)' => 'node_modules#update_platform_items', on: :member
  end

  #
  # Node Mount Point Routes
  #
  resources :node_mount_points, path: 'mount_points'

  #
  # Node Platform Routes
  #
  resources :node_platforms, path: 'platforms'

  #
  # Node Script Routes
  #
  resources :node_scripts, path: 'scripts'

  #
  # Node Template Routes
  #
  resources :node_templates, path: 'templates' do
    collection do
      post 'import'
    end
    member do
      match 'export', via: [:get, :post]
    end
    get '/update_platform_items(/:node_platform_id)' => 'node_templates#update_platform_items', on: :collection
    get '/update_platform_items(/:node_platform_id)' => 'node_templates#update_platform_items', on: :member
  end

  #
  # Operation Routes
  #
  resources :operations do
    member do
      match '/control'    => 'operations#control',    via: [:delete, :get, :post],  as: :control
      match '/reschedule' => 'operations#reschedule', via: [:get, :post],           as: :reschedule
    end
  end

  #
  # Provider Availability Zone Routes
  #
  resources :provider_availability_zones, path: 'availability_zones'

  #
  # Provider Routes
  #
  resources :providers, path: 'providers'

  #
  # Provider Region Routes
  #
  resources :provider_regions, path: 'regions'

  #
  # Provider Connection Routes
  #
  resources :provider_connections, path: 'connections'

  #
  # Provider Instance Type Routes
  #
  resources :provider_instance_types, path: 'instance_types'

  #
  # Provider Network Routes
  #
  resources :provider_networks, path: 'networks'

  #
  # Provider Network Subnet Routes
  #
  resources :provider_network_subnets, path: 'subnets'

  #
  # Provider Volume Routes
  #
  resources :provider_volumes, path: 'volumes' do
    get '/update_provider_region_items(/:provider_region_id)' => 'provider_volumes#update_provider_region_items', on: :collection
    get '/update_provider_region_items(/:provider_region_id)' => 'provider_volumes#update_provider_region_items', on: :member
  end

  #
  # Provider Volume Type Routes
  #
  resources :provider_volume_types

  #
  # Puppet Module Routes
  #
  resources :puppet_modules

  namespace :api do
    namespace :agent_v1, defaults: { format: 'json' } do
      # Account resources
      match '/accounts(/:account_id)'                                                               => 'agent_api#accounts',                    via: [:get]
      match '(/accounts/:account_id)/nodes(/:node_id)'                                              => 'agent_api#nodes',                       via: [:get, :put]
      match '(/accounts/:account_id)/node_architectures(/:node_architecture_id)'                    => 'agent_api#node_architectures',          via: [:get]
      match '(/accounts/:account_id)/node_templates(/:node_template_id)'                            => 'agent_api#node_templates',              via: [:get]
      match '(/accounts/:account_id)(/:operable_type/:operable_id)/operations(/:operation_id)'      => 'agent_api#operations',                  via: [:get, :put]
      match '(/accounts/:account_id)/provider_availability_zones(/:provider_availability_zone_id)'  => 'agent_api#provider_availability_zones', via: [:get]
      match '(/accounts/:account_id)/provider_connections(/:provider_connection_id)'                => 'agent_api#provider_connections',        via: [:get]
      match '(/accounts/:account_id)/provider_instance_types(/:provider_instance_type_id)'          => 'agent_api#provider_instance_types',     via: [:get, :put]
      match '(/accounts/:account_id)/provider_networks(/:provider_network_id)'                      => 'agent_api#provider_networks',           via: [:get]
      match '(/accounts/:account_id)/provider_network_subnets(/:provider_network_subnet_id)'        => 'agent_api#provider_network_subnets',    via: [:get]
      match '(/accounts/:account_id)/provider_regions(/:provider_region_id)'                        => 'agent_api#provider_regions',            via: [:get, :put]
      match '(/accounts/:account_id)/volumes(/:volume_id)'                                          => 'agent_api#volumes',                     via: [:get, :post, :put]

      # Node and instance resources
      match '(/nodes/:node_id)/node_instances(/:node_instance_id)'                                  => 'agent_api#node_instances',              via: [:get, :post, :put, :delete]
      match '(/node_instances/:node_instance_id)/node_modules(/:node_module_id)'                    => 'agent_api#node_modules',                via: [:get, :post, :put]

      # Resource upload/download routes
      match '/node_architectures/:node_architecture_id/download/:resource'                          => 'agent_api#node_architecture_download',  via: [:get]
      match '/node_architectures/:node_architecture_id/upload/:resource'                            => 'agent_api#node_architecture_upload',    via: [:post]
      match '/node_instances/:node_instance_id/upload/:resource'                                    => 'agent_api#node_instance_upload',        via: [:post]
      match '/node_modules/:node_module_id/download/:resource'                                      => 'agent_api#node_module_download',        via: [:get]
      match '/node_modules/:node_module_id/upload/:resource'                                        => 'agent_api#node_module_upload',          via: [:post]
      match '/node_scripts/:node_script_id/download'                                                => 'agent_api#node_script_download',        via: [:get]

      # Catch all invalid routes
      match '/(*)'                                                                                  => 'agent_api#not_found',                   via: [:get, :post, :put, :delete], anchor: false
    end

    namespace :node_v1, defaults: { format: 'text' } do
      match '/instance/config'                  => 'node_api#node_instance_config',           via: [:get]
      match '/instance/authorized_keys'         => 'node_api#node_instance_authorized_keys',  via: [:get]
      match '/instance/host_keys'               => 'node_api#node_instance_host_keys',        via: [:get]
      match '/modules'                          => 'node_api#node_modules',                   via: [:get]
      match '/module/:node_module_id'           => 'node_api#node_module',                    via: [:get]
      match '/module/:node_module_id/:resource' => 'node_api#node_module_resource',           via: [:get]
      match '/mount_points'                     => 'node_api#node_mount_points',              via: [:get]
      match '/puppet/resources'                 => 'node_api#puppet_resources',               via: [:get]
      match '/script/:node_script_id'           => 'node_api#node_script',                    via: [:get]
      match '/status'                           => 'node_api#status',                         via: [:get]

      # Catch all invalid routes
      match '/(*)'                              => 'node_api#not_found',                      anchor: false,
                                                                                              via: [:get, :post, :put, :delete]
    end
  end

  match '*path' => 'pages#show', id: 'not_found', via: [:get, :post, :put, :delete]
end
