class InitialSchema < ActiveRecord::Migration
  enable_extension 'uuid-ossp'

  def change
    create_table :account_delegations, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :user_id,                                                           null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.datetime    :expiration
    end

    add_index :account_delegations, :account_id
    add_index :account_delegations, :user_id

    create_table :accounts, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :agent_id
      t.uuid        :owner_id,                                                          null: false
      t.string      :name,                                                              null: false
    end

    add_index :accounts, :owner_id

    create_table :agents, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.string      :proxy_url,                                         default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :primary,                                           default: false, null: false
      t.boolean     :public,                                            default: false, null: false
      t.integer     :roles_mask,                                        default: 0,     null: false
      t.text        :encrypted_key,                                     default: '',    null: false
    end

    add_index :agents, :account_id

    create_table :invitations, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default: 'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :subscription_id
      t.string      :recipient
    end

    add_index :invitations, :account_id
    add_index :invitations, :subscription_id

    create_table :node_architectures, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.integer     :tier,                                              default: 1,     null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
      t.attachment  :kernel
      t.string      :kernel_checksum,                                   default: '',    null: false
      t.attachment  :ramdisk
      t.string      :ramdisk_checksum,                                  default: '',    null: false
    end

    add_index :node_architectures, :account_id

    create_table :node_instance_types, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
      t.decimal     :runtime_cost,                                      default: 0.0,   null: false
      t.integer     :tier,                                              default: 1,     null: false
    end

    add_index :node_instance_types, :account_id

    create_table :node_instances, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :node_id,                                                           null: false
      t.uuid        :node_instance_type_id
      t.uuid        :provider_id
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :private_netboot_enabled,                           default: false, null: false
      t.float       :latitude
      t.float       :longitude
      t.attachment  :image
      t.string      :image_checksum
      t.string      :image_format,                                      default: '',    null: false
      t.string      :address
      t.string      :address_full
      t.string      :entity
      t.string      :private_ip_address
      t.string      :private_mac_address
      t.string      :public_ip_address
      t.string      :status,                                                            null: false
      t.string      :variety,                                                           null: false
      t.boolean     :private_ip_static,                                 default: false, null: false
      t.string      :private_ip_device
      t.string      :private_ip_domain
      t.string      :private_ip_gateway
      t.string      :private_ip_netmask
      t.string      :private_ip_primary_dns
      t.string      :private_ip_secondary_dns
      t.text        :encrypted_key
      t.text        :agent_key
      t.datetime    :private_netboot_updated_at
      t.datetime    :started_at
    end

    add_index :node_instances, :name
    add_index :node_instances, :node_id
    add_index :node_instances, :provider_id

    create_table :node_module_categories, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :config_category_id
      t.uuid        :instance_category_id
      t.string      :variety,                                                           null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
      t.integer     :priority,                                                          null: false
      t.integer     :tier,                                              default: 1,     null: false
    end

    add_index :node_module_categories, :account_id
    add_index :node_module_categories, :config_category_id
    add_index :node_module_categories, :instance_category_id

    create_table :node_module_copy_paths, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.string      :path,                                                              null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
    end

    add_index :node_module_copy_paths, :account_id

    create_table :node_module_dependencies, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :node_module_id
      t.uuid        :node_module_dependency_id
    end

    add_index :node_module_dependencies, :node_module_id
    add_index :node_module_dependencies, :node_module_dependency_id

    create_table :node_module_subscriptions, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :node_id,                                                           null: false
      t.uuid        :node_module_id,                                                    null: false
      t.uuid        :node_module_copy_path_id
      t.boolean     :enabled,                                           default: true,  null: false
    end

    add_index :node_module_subscriptions, :node_id
    add_index :node_module_subscriptions, :node_module_id
    add_index :node_module_subscriptions, :node_module_copy_path_id

    create_table :node_modules, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :build_script_id
      t.uuid        :node_instance_id
      t.uuid        :node_module_category_id
      t.uuid        :node_module_subscription_id
      t.uuid        :node_platform_id
      t.string      :name
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.boolean     :configurable,                                      default: false, null: false
      t.boolean     :custom_build_script,                               default: false, null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :immutable,                                         default: false, null: false
      t.boolean     :provisional,                                       default: false, null: false
      t.boolean     :public,                                            default: false, null: false
      t.boolean     :reboot_required,                                   default: false, null: false
      t.boolean     :required,                                          default: false, null: false
      t.integer     :priority,                                          default: 50,    null: false
      t.integer     :version
      t.attachment  :data
      t.string      :data_checksum,                                     default: '',    null: false
      t.string      :init_restart,                                      default: '',    null: false
      t.string      :init_start,                                        default: '',    null: false
      t.string      :init_stop,                                         default: '',    null: false
      t.string      :variety,                                                           null: false
      t.text        :dependency_spec,                                   default: '[]',  null: false
      t.text        :package_spec,                                      default: '[]',  null: false
      t.text        :spec,                                              default: '[]',  null: false
      t.text        :mask,                                              default: '[]',  null: false
    end

    add_index :node_modules, :account_id
    add_index :node_modules, :node_instance_id
    add_index :node_modules, :node_module_category_id
    add_index :node_modules, :node_module_subscription_id
    add_index :node_modules, :node_platform_id

    create_table :node_module_versions, id: false do |t|
      t.timestamps                                                                      null: false
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :node_module_id
      t.integer     :version
      t.attachment  :data
      t.string      :data_checksum
    end

    add_index :node_module_versions, :node_module_id

    create_table :node_mount_points, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :node_mount_point_dependency_id
      t.uuid        :mount_script_id
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.text        :options,                                           default: '{}',  null: false
      t.string      :device,                                                            null: false
      t.string      :path,                                                              null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
    end

    add_index :node_mount_points, :account_id
    add_index :node_mount_points, :node_mount_point_dependency_id

    create_table :node_mount_point_subscriptions, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :node_id,                                                           null: false
      t.uuid        :node_mount_point_id,                                               null: false
    end

    add_index :node_mount_point_subscriptions, :node_id
    add_index :node_mount_point_subscriptions, :node_mount_point_id

    create_table :node_platforms, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :build_script_id
      t.uuid        :init_script_id
      t.uuid        :sync_script_id
      t.uuid        :node_architecture_id,                                              null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           defailt: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
    end

    add_index :node_platforms, :account_id
    add_index :node_platforms, :node_architecture_id

    create_table :node_scripts, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.string      :variety,                                                           null: false
      t.text        :details,                                           default: '',    null: false
      t.text        :data,                                              default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
    end

    add_index :node_scripts, :account_id
    add_index :node_scripts, :name

    create_table :node_template_module_subscriptions, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :node_module_id,                                                    null: false
      t.uuid        :node_template_id,                                                  null: false
    end

    add_index :node_template_module_subscriptions, :node_module_id
    add_index :node_template_module_subscriptions, :node_template_id

    create_table :node_templates, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :node_platform_id,                                                  null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
      t.decimal     :runtime_cost,                                      default: 0.0
      t.integer     :tier,                                              default: 1,     null: false
      t.string      :admin_user
    end

    add_index :node_templates, :account_id
    add_index :node_templates, :node_platform_id

    create_table :nodes, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :node_balancer_id
      t.uuid        :node_instance_type_id,                                             null: false
      t.uuid        :node_template_id,                                                  null: false
      t.uuid        :primary_instance_id
      t.uuid        :provider_id,                                                       null: false
      t.uuid        :sync_script_id
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.boolean     :auto_scaling,                                      default: false, null: false
      t.boolean     :custom_sync_script,                                default: false, null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :tmpfs_store,                                       default: false, null: false
      t.decimal     :runtime_amount,                                    default: 0.0
      t.integer     :dynamic_instance_count,                            default: 0
      t.integer     :dynamic_instance_max,                              default: 1
      t.integer     :dynamic_instance_min,                              default: 0
      t.string      :proxy_url,                                         default: '',    null: false
      t.string      :public_address,                                    default: '',    null: false
      t.string      :ssh_key_fingerprint,                               default: '',    null: false
      t.text        :ssh_key,                                           default: '',    null: false
    end

    add_index :nodes, :account_id
    add_index :nodes, :node_balancer_id
    add_index :nodes, :node_instance_type_id
    add_index :nodes, :provider_id
    add_index :nodes, :node_template_id

    create_table :notifications, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.string      :category,                                                          null: false
      t.text        :content,                                           default: '',    null: false
      t.text        :summary,                                                           null: false
    end

    add_index :notifications, :account_id

    create_table :operations, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :node_id,                                                           null: false
      t.uuid        :node_instance_id
      t.uuid        :node_module_id
      t.uuid        :volume_id
      t.string      :command,                                                           null: false
      t.string      :status,                                                            null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :options,                                           default: '{}',  null: false
      t.boolean     :exclusive,                                         default: false, null: false
      t.datetime    :scheduled_at
    end

    add_index :operations, :account_id
    add_index :operations, :node_id
    add_index :operations, :node_instance_id
    add_index :operations, :node_module_id
    add_index :operations, :volume_id

    create_table :pages, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.string      :name,                                                              null: false
      t.string      :title
      t.string      :description,                                       default: '',    null: false
      t.text        :content,                                           default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
    end

    add_index :pages, :name

    create_table :providers, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :provider_endpoint_id,                                              null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
      t.integer     :tier,                                              default: 1,     null: false
      t.string      :access_key
      t.string      :secret_key
      t.string      :tenant,                                            default: '',    null: false
    end

    add_index :providers, :account_id

    create_table :provider_endpoints, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :provider_endpoint_type_id,                                         null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
      t.string      :availability_zone,                                 default: '',    null: false
      t.string      :endpoint_url,                                      default: '',    null: false
      t.string      :kernel_image
      t.string      :machine_image
      t.string      :ramdisk_image
      t.string      :region
    end

    add_index :provider_endpoints, :account_id

    create_table :provider_endpoint_instance_type_subscriptions, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :provider_endpoint_id,                                              null: false
      t.uuid        :node_instance_type_id,                                             null: false
    end

    add_index :provider_endpoint_instance_type_subscriptions, :provider_endpoint_id, name: 'index_endpoint_instance_type_sub_on_provider_endpoint_id'
    add_index :provider_endpoint_instance_type_subscriptions, :node_instance_type_id, name: 'index_endpoint_instance_type_sub_on_node_instance_type_id'

    create_table :provider_endpoint_volume_type_subscriptions, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid :provider_endpoint_id,                                                     null: false
      t.uuid :volume_type_id,                                                           null: false
    end

    add_index :provider_endpoint_volume_type_subscriptions, :provider_endpoint_id, name: 'index_endpoint_volume_type_sub_on_endpoint_id'
    add_index :provider_endpoint_volume_type_subscriptions, :volume_type_id, name: 'index_endpoint_volume_type_sub_on_volume_type_id'

    create_table :provider_endpoint_types, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
    end

    create_table :puppet_modules, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.attachment  :data
      t.string      :data_checksum,                                     default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
      t.boolean     :public,                                            default: false, null: false
    end

    add_index :puppet_modules, :name

    create_table :puppet_resources, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :puppet_module_id,                                                  null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :data,                                              default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.string      :path,                                              default: '',    null: false
      t.boolean     :enabled,                                           default: true,  null: false
    end

    add_index :puppet_resources, :name

    create_table :node_module_puppet_module_subscriptions, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :node_module_id,                                                    null: false
      t.uuid        :puppet_module_id,                                                  null: false
    end

    add_index :node_module_puppet_module_subscriptions, :node_module_id, name: 'index_node_module_puppet_module_sub_on_node_module_id'
    add_index :node_module_puppet_module_subscriptions, :puppet_module_id, name: 'index_node_module_puppet_module_sub_on_puppet_module_id'

    create_table :subscription_affiliates, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id
      t.string      :name,                                                              null: false
      t.string      :token,                                             default: '',    null: false
      t.decimal     :rate,                  precision: 6,   scale: 4,   default: 0.0,   null: false
    end

    add_index :subscription_affiliates, :account_id
    add_index :subscription_affiliates, :token

    create_table :subscription_discounts, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.string      :name,                                                              null: false
      t.string      :code,                                              default: '',    null: false
      t.boolean     :apply_to_setup,                                    default: false, null: false
      t.boolean     :apply_to_recurring,                                default: false, null: false
      t.boolean     :percent,                                           default: false, null: false
      t.datetime    :start_on
      t.datetime    :end_on
      t.decimal     :amount,                precision: 6,   scale: 2,   default: 0.0
      t.integer     :trial_period_extension,                            default: 0
    end

    add_index :subscription_discounts, :code

    create_table :subscription_payments, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :subscriber_id
      t.uuid        :subscription_id
      t.uuid        :subscription_affiliate_id
      t.boolean     :setup,                                             default: false, null: false
      t.boolean     :misc,                                              default: false, null: false
      t.decimal     :affiliate_amount,      precision: 6,   scale: 2,   default: 0.0
      t.decimal     :amount,                precision: 10,  scale: 2,   default: 0.0
      t.string      :subscriber_type,                                   default: 'User'
      t.string      :transaction_id,                                                    null: false
    end

    add_index :subscription_payments, [:subscriber_id, :subscriber_type], name: 'index_subscription_payments_on_subscriber_id_and_type'
    add_index :subscription_payments, :subscription_affiliate_id
    add_index :subscription_payments, :subscription_id

    create_table :subscription_plans, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.boolean     :featured,                                          default: false, null: false
      t.decimal     :amount,                precision: 10,  scale: 2,   default: 0
      t.decimal     :setup_amount,          precision: 10,  scale: 2,   default: 0
      t.float       :unit_price
      t.integer     :renewal_period,                                    default: 1
      t.string      :trial_interval,                                    default: 'months'
      t.integer     :trial_period,                                      default: 1
      t.integer     :user_limit,                                        default: 1,     null: false
      t.integer     :node_limit,                                        default: 1,     null: false
      t.integer     :instance_limit,                                    default: 1,     null: false
      t.integer     :tier_limit,                                        default: 1,     null: false
      t.text        :default_roles,                                     default: '[]',  null: false
    end

    create_table :subscriptions, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :subscriber_id
      t.uuid        :subscription_affiliate_id
      t.uuid        :subscription_discount_id
      t.uuid        :subscription_plan_id
      t.decimal     :amount,                precision: 10,  scale: 2
      t.decimal     :prorate_amount,        precision: 12,  scale: 6,   default: 0.0
      t.decimal     :runtime_amount,        precision: 12,  scale: 6,   default: 0.0
      t.decimal     :storage_amount,        precision: 12,  scale: 6,   default: 0.0
      t.decimal     :traffic_amount,        precision: 12,  scale: 6,   default: 0.0
      t.datetime    :next_renewal_at
      t.integer     :instance_limit,                                                    null: false
      t.integer     :node_limit,                                                        null: false
      t.integer     :renewal_period,                                    default: 1
      t.integer     :tier_limit,                                                        null: false
      t.integer     :user_limit,                                                        null: false
      t.string      :billing_id
      t.string      :card_number
      t.string      :card_expiration
      t.string      :state,                                             default: 'trial'
      t.string      :subscriber_type,                                   default: 'User'
    end

    add_index :subscriptions, [:subscriber_id, :subscriber_type]

    create_table :users, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id
      t.string      :email,                                             default: '',    null: false
      t.string      :encrypted_password,                                default: '',    null: false
      t.integer     :failed_attempts,                                   default: 0
      t.string      :locale,                                                            null: false
      t.string      :name,                                                              null: false
      t.integer     :roles_mask,                                        default: 0,     null: false
      # Confirmable
      t.string      :confirmation_token
      t.datetime    :confirmed_at
      t.datetime    :confirmation_sent_at
      t.string      :unconfirmed_email
      # Recoverable
      t.datetime    :reset_password_sent_at
      t.string      :reset_password_token
      # Rememberable
      t.datetime    :remember_created_at
      # Trackable
      t.integer     :sign_in_count,                                     default: 0,     null: false
      t.datetime    :current_sign_in_at
      t.datetime    :last_sign_in_at
      t.string      :current_sign_in_ip
      t.string      :last_sign_in_ip
      # Lockable
      t.integer     :failed_attempts,                                   default: 0,     null: false
      t.string      :unlock_token
      t.datetime    :locked_at
    end

    add_index :users, :account_id
    add_index :users, :confirmation_token,      unique: true
    add_index :users, :email,                   unique: true
    add_index :users, :reset_password_token,    unique: true
    add_index :users, :unlock_token,            unique: true

    create_table :volumes, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :active_instance_id
      t.uuid        :node_instance_id
      t.uuid        :node_module_id
      t.uuid        :mount_script_id
      t.uuid        :provider_id,                                                       null: false
      t.uuid        :volume_type_id,                                                    null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.string      :mount_point,                                       default: '',    null: false
      t.text        :options,                                           default: '{}',  null: false
      t.string      :status,                                                            null: false
      t.boolean     :custom_mount_script,                               default: false, null: false
      t.boolean     :mounted,                                           default: false, null: false
      t.boolean     :raid,                                              default: false, null: false
      t.integer     :raid_level,                                        default: 0,     null: false
      t.integer     :size,                                              default: 1,     null: false
      t.column      :used, :bigint,                                     default: 0,     null: false
    end

    add_index :volumes, :account_id

    create_table :volume_members, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :volume_id,                                                         null: false
      t.string      :entity,                                            default: '',    null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.string      :device,                                            default: '',    null: false
      t.string      :status,                                                            null: false
    end

    add_index :volume_members, :volume_id

    create_table :volume_snapshots, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :volume_id,                                                         null: false
      t.string      :entity,                                            default: '',    null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.string      :status,                                                            null: false
    end

    add_index :volume_snapshots, :volume_id

    create_table :volume_types, id: false do |t|
      t.timestamps
      t.primary_key :id, :uuid, default:  'uuid_generate_v1()'
      t.uuid        :account_id,                                                        null: false
      t.uuid        :mount_script_id,                                                   null: false
      t.string      :name,                                                              null: false
      t.string      :description,                                       default: '',    null: false
      t.text        :details,                                           default: '',    null: false
      t.text        :options,                                           default: '{}',  null: false
      t.boolean     :enabled,                                           default: false, null: false
      t.boolean     :public,                                            default: false, null: false
    end

    add_index :volume_types, :account_id
  end
end
