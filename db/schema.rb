# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151012004006) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "account_delegations", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
    t.uuid     "account_id",                                         null: false
    t.uuid     "user_id",                                            null: false
    t.string   "description", limit: 255,               default: "", null: false
    t.text     "details",                               default: "", null: false
    t.datetime "expiration",              precision: 6
  end

  add_index "account_delegations", ["account_id"], name: "index_account_delegations_on_account_id", using: :btree
  add_index "account_delegations", ["user_id"], name: "index_account_delegations_on_user_id", using: :btree

  create_table "accounts", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                         precision: 6
    t.datetime "updated_at",                         precision: 6
    t.uuid     "agent_id"
    t.uuid     "owner_id",                                                      null: false
    t.string   "name",                   limit: 255,                            null: false
    t.text     "encryption_key"
    t.uuid     "plan_id"
    t.string   "state"
    t.string   "stripe_card"
    t.string   "stripe_card_exp_month"
    t.string   "stripe_card_exp_year"
    t.string   "stripe_card_last4"
    t.string   "stripe_subscription"
    t.string   "stripe_token"
    t.string   "stripe_trial_end"
    t.string   "stripe_trial_start"
    t.string   "stripe_access_token",                              default: "", null: false
    t.string   "stripe_publishable_key",                           default: "", null: false
    t.string   "stripe_user",                                      default: "", null: false
  end

  add_index "accounts", ["owner_id"], name: "index_accounts_on_owner_id", using: :btree

  create_table "agents", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                precision: 6
    t.datetime "updated_at",                precision: 6
    t.uuid     "account_id",                                              null: false
    t.string   "name",          limit: 255,                               null: false
    t.string   "description",   limit: 255,               default: "",    null: false
    t.text     "details",                                 default: "",    null: false
    t.string   "proxy_url",     limit: 255,               default: "",    null: false
    t.boolean  "enabled",                                 default: true,  null: false
    t.boolean  "primary",                                 default: false, null: false
    t.boolean  "public",                                  default: false, null: false
    t.integer  "roles_mask",                              default: 0,     null: false
    t.text     "encrypted_key",                           default: "",    null: false
  end

  add_index "agents", ["account_id"], name: "index_agents_on_account_id", using: :btree

  create_table "invitations", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",             precision: 6
    t.datetime "updated_at",             precision: 6
    t.uuid     "account_id",                                        null: false
    t.uuid     "user_id"
    t.string   "recipient",  limit: 255,               default: "", null: false
  end

  add_index "invitations", ["account_id"], name: "index_invitations_on_account_id", using: :btree
  add_index "invitations", ["user_id"], name: "index_invitations_on_user_id", using: :btree

  create_table "node_architectures", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                       precision: 6
    t.datetime "updated_at",                       precision: 6
    t.uuid     "account_id",                                                     null: false
    t.string   "name",                 limit: 255,                               null: false
    t.string   "description",          limit: 255,               default: "",    null: false
    t.text     "details",                                        default: "",    null: false
    t.boolean  "enabled",                                        default: true,  null: false
    t.boolean  "public",                                         default: false, null: false
    t.string   "kernel_file_name",     limit: 255
    t.string   "kernel_content_type",  limit: 255
    t.integer  "kernel_file_size"
    t.datetime "kernel_updated_at",                precision: 6
    t.string   "kernel_checksum",      limit: 255,               default: "",    null: false
    t.string   "ramdisk_file_name",    limit: 255
    t.string   "ramdisk_content_type", limit: 255
    t.integer  "ramdisk_file_size"
    t.datetime "ramdisk_updated_at",               precision: 6
    t.string   "ramdisk_checksum",     limit: 255,               default: "",    null: false
    t.string   "image_file_name",      limit: 255
    t.string   "image_content_type",   limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at",                 precision: 6
    t.string   "image_checksum",       limit: 255,               default: "",    null: false
  end

  add_index "node_architectures", ["account_id"], name: "index_node_architectures_on_account_id", using: :btree

  create_table "node_instances", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                                precision: 6
    t.datetime "updated_at",                                precision: 6
    t.uuid     "node_id",                                                                 null: false
    t.uuid     "provider_instance_type_id"
    t.uuid     "provider_connection_id"
    t.string   "name",                          limit: 255,                               null: false
    t.string   "description",                   limit: 255,               default: "",    null: false
    t.text     "details",                                                 default: "",    null: false
    t.boolean  "enabled",                                                 default: true,  null: false
    t.boolean  "private_netboot_enabled",                                 default: false, null: false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "image_file_name",               limit: 255
    t.string   "image_content_type",            limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at",                          precision: 6
    t.string   "image_checksum",                limit: 255
    t.string   "image_format",                  limit: 255,               default: "",    null: false
    t.string   "address",                       limit: 255
    t.string   "address_full",                  limit: 255
    t.string   "entity",                        limit: 255
    t.string   "private_ip_address",            limit: 255
    t.string   "private_mac_address",           limit: 255
    t.string   "public_ip_address",             limit: 255
    t.string   "status",                        limit: 255,                               null: false
    t.string   "variety",                       limit: 255,                               null: false
    t.boolean  "private_ip_static",                                       default: false, null: false
    t.string   "private_ip_device",             limit: 255
    t.string   "private_ip_domain",             limit: 255
    t.string   "private_ip_gateway",            limit: 255
    t.string   "private_ip_netmask",            limit: 255
    t.string   "private_ip_primary_dns",        limit: 255
    t.string   "private_ip_secondary_dns",      limit: 255
    t.text     "encrypted_key"
    t.datetime "private_netboot_updated_at",                precision: 6
    t.datetime "started_at",                                precision: 6
    t.uuid     "provider_region_id"
    t.uuid     "provider_network_subnet_id"
    t.uuid     "provider_availability_zone_id"
  end

  add_index "node_instances", ["name"], name: "index_node_instances_on_name", using: :btree
  add_index "node_instances", ["node_id"], name: "index_node_instances_on_node_id", using: :btree
  add_index "node_instances", ["provider_connection_id"], name: "index_node_instances_on_provider_connection_id", using: :btree

  create_table "node_module_categories", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                       precision: 6
    t.datetime "updated_at",                       precision: 6
    t.uuid     "account_id",                                                     null: false
    t.uuid     "config_category_id"
    t.uuid     "instance_category_id"
    t.string   "variety",              limit: 255,                               null: false
    t.string   "name",                 limit: 255,                               null: false
    t.string   "description",          limit: 255,               default: "",    null: false
    t.text     "details",                                        default: "",    null: false
    t.boolean  "enabled",                                        default: true,  null: false
    t.boolean  "public",                                         default: false, null: false
    t.integer  "priority",                                                       null: false
  end

  add_index "node_module_categories", ["account_id"], name: "index_node_module_categories_on_account_id", using: :btree
  add_index "node_module_categories", ["config_category_id"], name: "index_node_module_categories_on_config_category_id", using: :btree
  add_index "node_module_categories", ["instance_category_id"], name: "index_node_module_categories_on_instance_category_id", using: :btree

  create_table "node_module_copy_paths", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
    t.uuid     "account_id",                                            null: false
    t.string   "name",        limit: 255,                               null: false
    t.string   "description", limit: 255,               default: "",    null: false
    t.text     "details",                               default: "",    null: false
    t.string   "path",        limit: 255,                               null: false
    t.boolean  "enabled",                               default: true,  null: false
    t.boolean  "public",                                default: false, null: false
  end

  add_index "node_module_copy_paths", ["account_id"], name: "index_node_module_copy_paths_on_account_id", using: :btree

  create_table "node_module_dependencies", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                precision: 6
    t.datetime "updated_at",                precision: 6
    t.uuid     "node_module_id"
    t.uuid     "node_module_dependency_id"
  end

  add_index "node_module_dependencies", ["node_module_dependency_id"], name: "index_node_module_dependencies_on_node_module_dependency_id", using: :btree
  add_index "node_module_dependencies", ["node_module_id"], name: "index_node_module_dependencies_on_node_module_id", using: :btree

  create_table "node_module_puppet_module_subscriptions", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",       precision: 6
    t.datetime "updated_at",       precision: 6
    t.uuid     "node_module_id",                 null: false
    t.uuid     "puppet_module_id",               null: false
  end

  add_index "node_module_puppet_module_subscriptions", ["node_module_id"], name: "index_node_module_puppet_module_sub_on_node_module_id", using: :btree
  add_index "node_module_puppet_module_subscriptions", ["puppet_module_id"], name: "index_node_module_puppet_module_sub_on_puppet_module_id", using: :btree

  create_table "node_module_subscriptions", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",               precision: 6
    t.datetime "updated_at",               precision: 6
    t.uuid     "node_id",                                               null: false
    t.uuid     "node_module_id",                                        null: false
    t.uuid     "node_module_copy_path_id"
    t.boolean  "enabled",                                default: true, null: false
  end

  add_index "node_module_subscriptions", ["node_id"], name: "index_node_module_subscriptions_on_node_id", using: :btree
  add_index "node_module_subscriptions", ["node_module_copy_path_id"], name: "index_node_module_subscriptions_on_node_module_copy_path_id", using: :btree
  add_index "node_module_subscriptions", ["node_module_id"], name: "index_node_module_subscriptions_on_node_module_id", using: :btree

  create_table "node_module_versions", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                    precision: 6, null: false
    t.datetime "updated_at",                    precision: 6, null: false
    t.uuid     "node_module_id"
    t.integer  "version"
    t.string   "data_file_name",    limit: 255
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size"
    t.datetime "data_updated_at",               precision: 6
    t.string   "data_checksum",     limit: 255
  end

  add_index "node_module_versions", ["node_module_id"], name: "index_node_module_versions_on_node_module_id", using: :btree

  create_table "node_modules", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                              precision: 6
    t.datetime "updated_at",                              precision: 6
    t.uuid     "account_id",                                                            null: false
    t.uuid     "build_script_id"
    t.uuid     "node_instance_id"
    t.uuid     "node_module_category_id"
    t.uuid     "node_module_subscription_id"
    t.uuid     "node_platform_id"
    t.string   "name",                        limit: 255
    t.string   "description",                 limit: 255,               default: "",    null: false
    t.text     "details",                                               default: "",    null: false
    t.boolean  "configurable",                                          default: false, null: false
    t.boolean  "custom_build_script",                                   default: false, null: false
    t.boolean  "enabled",                                               default: true,  null: false
    t.boolean  "immutable",                                             default: false, null: false
    t.boolean  "provisional",                                           default: false, null: false
    t.boolean  "public",                                                default: false, null: false
    t.boolean  "reboot_required",                                       default: false, null: false
    t.boolean  "required",                                              default: false, null: false
    t.integer  "priority",                                              default: 50,    null: false
    t.integer  "version"
    t.string   "data_file_name",              limit: 255
    t.string   "data_content_type",           limit: 255
    t.integer  "data_file_size"
    t.datetime "data_updated_at",                         precision: 6
    t.string   "data_checksum",               limit: 255,               default: "",    null: false
    t.string   "init_restart",                limit: 255,               default: "",    null: false
    t.string   "init_start",                  limit: 255,               default: "",    null: false
    t.string   "init_stop",                   limit: 255,               default: "",    null: false
    t.string   "variety",                     limit: 255,                               null: false
    t.text     "dependency_spec",                                       default: "[]",  null: false
    t.text     "package_spec",                                          default: "[]",  null: false
    t.text     "spec",                                                  default: "[]",  null: false
    t.text     "mask",                                                  default: "[]",  null: false
    t.boolean  "lock_spec",                                             default: false, null: false
  end

  add_index "node_modules", ["account_id"], name: "index_node_modules_on_account_id", using: :btree
  add_index "node_modules", ["node_instance_id"], name: "index_node_modules_on_node_instance_id", using: :btree
  add_index "node_modules", ["node_module_category_id"], name: "index_node_modules_on_node_module_category_id", using: :btree
  add_index "node_modules", ["node_module_subscription_id"], name: "index_node_modules_on_node_module_subscription_id", using: :btree
  add_index "node_modules", ["node_platform_id"], name: "index_node_modules_on_node_platform_id", using: :btree

  create_table "node_mount_point_subscriptions", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",          precision: 6
    t.datetime "updated_at",          precision: 6
    t.uuid     "node_instance_id",                  null: false
    t.uuid     "node_mount_point_id",               null: false
  end

  add_index "node_mount_point_subscriptions", ["node_instance_id"], name: "index_node_mount_point_subscriptions_on_node_instance_id", using: :btree
  add_index "node_mount_point_subscriptions", ["node_mount_point_id"], name: "index_node_mount_point_subscriptions_on_node_mount_point_id", using: :btree

  create_table "node_mount_points", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                                 precision: 6
    t.datetime "updated_at",                                 precision: 6
    t.uuid     "account_id",                                                               null: false
    t.uuid     "node_mount_point_dependency_id"
    t.uuid     "mount_script_id"
    t.string   "name",                           limit: 255,                               null: false
    t.string   "description",                    limit: 255,               default: "",    null: false
    t.text     "details",                                                  default: "",    null: false
    t.text     "options",                                                  default: "{}",  null: false
    t.string   "device",                         limit: 255,                               null: false
    t.string   "path",                           limit: 255,                               null: false
    t.boolean  "enabled",                                                  default: true,  null: false
    t.boolean  "public",                                                   default: false, null: false
    t.uuid     "node_module_id"
  end

  add_index "node_mount_points", ["account_id"], name: "index_node_mount_points_on_account_id", using: :btree
  add_index "node_mount_points", ["node_mount_point_dependency_id"], name: "index_node_mount_points_on_node_mount_point_dependency_id", using: :btree

  create_table "node_platforms", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                       precision: 6
    t.datetime "updated_at",                       precision: 6
    t.uuid     "account_id",                                                     null: false
    t.uuid     "build_script_id"
    t.uuid     "init_script_id"
    t.uuid     "sync_script_id"
    t.uuid     "node_architecture_id",                                           null: false
    t.string   "name",                 limit: 255,                               null: false
    t.string   "description",          limit: 255,               default: "",    null: false
    t.text     "details",                                                        null: false
    t.boolean  "enabled",                                        default: true,  null: false
    t.boolean  "public",                                         default: false, null: false
  end

  add_index "node_platforms", ["account_id"], name: "index_node_platforms_on_account_id", using: :btree
  add_index "node_platforms", ["node_architecture_id"], name: "index_node_platforms_on_node_architecture_id", using: :btree

  create_table "node_scripts", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
    t.uuid     "account_id",                                            null: false
    t.string   "name",        limit: 255,                               null: false
    t.string   "description", limit: 255,               default: "",    null: false
    t.string   "variety",     limit: 255,                               null: false
    t.text     "details",                               default: "",    null: false
    t.text     "data",                                  default: "",    null: false
    t.boolean  "enabled",                               default: true,  null: false
    t.boolean  "public",                                default: false, null: false
  end

  add_index "node_scripts", ["account_id"], name: "index_node_scripts_on_account_id", using: :btree
  add_index "node_scripts", ["name"], name: "index_node_scripts_on_name", using: :btree

  create_table "node_template_module_subscriptions", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",       precision: 6
    t.datetime "updated_at",       precision: 6
    t.uuid     "node_module_id",                 null: false
    t.uuid     "node_template_id",               null: false
  end

  add_index "node_template_module_subscriptions", ["node_module_id"], name: "index_node_template_module_subscriptions_on_node_module_id", using: :btree
  add_index "node_template_module_subscriptions", ["node_template_id"], name: "index_node_template_module_subscriptions_on_node_template_id", using: :btree

  create_table "node_templates", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                   precision: 6
    t.datetime "updated_at",                   precision: 6
    t.uuid     "account_id",                                                 null: false
    t.uuid     "node_platform_id",                                           null: false
    t.string   "name",             limit: 255,                               null: false
    t.string   "description",      limit: 255,               default: "",    null: false
    t.text     "details",                                    default: "",    null: false
    t.boolean  "enabled",                                    default: true,  null: false
    t.boolean  "public",                                     default: false, null: false
    t.string   "admin_user",       limit: 255
  end

  add_index "node_templates", ["account_id"], name: "index_node_templates_on_account_id", using: :btree
  add_index "node_templates", ["node_platform_id"], name: "index_node_templates_on_node_platform_id", using: :btree

  create_table "nodes", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                      precision: 6
    t.datetime "updated_at",                      precision: 6
    t.uuid     "account_id",                                                    null: false
    t.uuid     "node_template_id",                                              null: false
    t.uuid     "primary_instance_id"
    t.uuid     "sync_script_id"
    t.string   "name",                limit: 255,                               null: false
    t.string   "description",         limit: 255,               default: "",    null: false
    t.text     "details",                                       default: "",    null: false
    t.boolean  "custom_sync_script",                            default: false, null: false
    t.boolean  "enabled",                                       default: true,  null: false
    t.boolean  "tmpfs_store",                                   default: false, null: false
    t.decimal  "runtime_amount",                                default: 0.0
    t.string   "public_address",      limit: 255,               default: "",    null: false
    t.string   "ssh_key_fingerprint", limit: 255,               default: "",    null: false
    t.text     "encrypted_ssh_key",                             default: "",    null: false
    t.boolean  "allocate_public_ip",                            default: true,  null: false
    t.uuid     "agent_id"
  end

  add_index "nodes", ["account_id"], name: "index_nodes_on_account_id", using: :btree
  add_index "nodes", ["node_template_id"], name: "index_nodes_on_node_template_id", using: :btree

  create_table "operations", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                precision: 6
    t.datetime "updated_at",                precision: 6
    t.uuid     "account_id",                                              null: false
    t.string   "command",       limit: 255,                               null: false
    t.string   "status",        limit: 255,                               null: false
    t.string   "description",   limit: 255,               default: "",    null: false
    t.text     "options",                                 default: "{}",  null: false
    t.boolean  "exclusive",                               default: false, null: false
    t.datetime "scheduled_at",              precision: 6
    t.uuid     "operable_id",                                             null: false
    t.string   "operable_type", limit: 255,                               null: false
    t.integer  "progress",                                default: 0,     null: false
    t.text     "events",                                  default: "[]",  null: false
    t.string   "icon",                                    default: "",    null: false
  end

  add_index "operations", ["account_id"], name: "index_operations_on_account_id", using: :btree

  create_table "pages", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
    t.string   "name",        limit: 255,                               null: false
    t.string   "title",       limit: 255
    t.string   "description", limit: 255,               default: "",    null: false
    t.text     "content",                               default: "",    null: false
    t.boolean  "enabled",                               default: true,  null: false
    t.boolean  "public",                                default: false, null: false
    t.uuid     "account_id"
  end

  add_index "pages", ["account_id"], name: "index_pages_on_account_id", using: :btree
  add_index "pages", ["name"], name: "index_pages_on_name", using: :btree

  create_table "plans", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                       precision: 6
    t.datetime "updated_at",                       precision: 6
    t.string   "name",                 limit: 255,                                             null: false
    t.string   "description",          limit: 255,                          default: "",       null: false
    t.text     "details",                                                   default: "",       null: false
    t.boolean  "featured",                                                  default: false,    null: false
    t.decimal  "amount",                           precision: 10, scale: 2, default: 0.0
    t.string   "interval",             limit: 255,                          default: "months"
    t.integer  "interval_count",                                            default: 1
    t.integer  "user_limit",                                                default: 1,        null: false
    t.integer  "node_limit",                                                default: 1,        null: false
    t.integer  "instance_limit",                                            default: 1,        null: false
    t.text     "default_roles",                                             default: "[]",     null: false
    t.string   "currency",                                                  default: "usd",    null: false
    t.string   "statement_descriptor", limit: 22
    t.integer  "trial_period_days"
    t.uuid     "account_id"
    t.boolean  "enabled",                                                   default: true,     null: false
    t.boolean  "public",                                                    default: true,     null: false
  end

  add_index "plans", ["account_id"], name: "index_plans_on_account_id", using: :btree

  create_table "provider_availability_zones", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                     precision: 6
    t.datetime "updated_at",                     precision: 6
    t.uuid     "account_id",                                                   null: false
    t.uuid     "provider_region_id",                                           null: false
    t.string   "name",               limit: 255,                               null: false
    t.string   "description",        limit: 255,               default: "",    null: false
    t.text     "details",                                      default: "",    null: false
    t.string   "entity",             limit: 255,               default: "",    null: false
    t.boolean  "enabled",                                      default: false, null: false
    t.boolean  "public",                                       default: false, null: false
  end

  create_table "provider_connections", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                       precision: 6
    t.datetime "updated_at",                       precision: 6
    t.uuid     "account_id",                                                    null: false
    t.uuid     "provider_id",                                                   null: false
    t.string   "name",                 limit: 255,                              null: false
    t.string   "description",          limit: 255,               default: "",   null: false
    t.text     "details",                                        default: "",   null: false
    t.boolean  "enabled",                                        default: true, null: false
    t.string   "access_key",           limit: 255
    t.string   "encrypted_secret_key", limit: 255
    t.string   "tenant",               limit: 255,               default: "",   null: false
  end

  add_index "provider_connections", ["account_id"], name: "index_provider_connections_on_account_id", using: :btree

  create_table "provider_instance_types", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
    t.uuid     "account_id",                                            null: false
    t.string   "name",        limit: 255,                               null: false
    t.string   "description", limit: 255,               default: "",    null: false
    t.text     "details",                               default: "",    null: false
    t.boolean  "enabled",                               default: true,  null: false
    t.boolean  "public",                                default: false, null: false
  end

  add_index "provider_instance_types", ["account_id"], name: "index_provider_instance_types_on_account_id", using: :btree

  create_table "provider_network_subnets", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                                precision: 6
    t.datetime "updated_at",                                precision: 6
    t.uuid     "provider_network_id",                                                    null: false
    t.string   "name",                          limit: 255,                              null: false
    t.string   "description",                   limit: 255,               default: "",   null: false
    t.text     "details",                                                 default: "",   null: false
    t.string   "entity",                        limit: 255,               default: "",   null: false
    t.inet     "network",                                                                null: false
    t.uuid     "account_id",                                                             null: false
    t.boolean  "enabled",                                                 default: true, null: false
    t.uuid     "provider_availability_zone_id"
  end

  add_index "provider_network_subnets", ["provider_network_id"], name: "index_provider_network_subnets_on_provider_network_id", using: :btree

  create_table "provider_networks", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                     precision: 6
    t.datetime "updated_at",                     precision: 6
    t.uuid     "account_id",                                                  null: false
    t.uuid     "provider_region_id",                                          null: false
    t.inet     "network",                                                     null: false
    t.string   "name",               limit: 255,                              null: false
    t.string   "description",        limit: 255,               default: "",   null: false
    t.text     "details",                                      default: "",   null: false
    t.string   "entity",             limit: 255,               default: "",   null: false
    t.string   "dns1",               limit: 255,               default: "",   null: false
    t.string   "dns2",               limit: 255,               default: "",   null: false
    t.string   "ntp_server",         limit: 255,               default: "",   null: false
    t.string   "tenancy",            limit: 255,               default: "",   null: false
    t.string   "status",             limit: 255,                              null: false
    t.boolean  "enabled",                                      default: true, null: false
  end

  add_index "provider_networks", ["account_id"], name: "index_provider_networks_on_account_id", using: :btree
  add_index "provider_networks", ["provider_region_id"], name: "index_provider_networks_on_provider_region_id", using: :btree

  create_table "provider_region_instance_type_subscriptions", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                precision: 6
    t.datetime "updated_at",                precision: 6
    t.uuid     "provider_region_id",                      null: false
    t.uuid     "provider_instance_type_id",               null: false
  end

  add_index "provider_region_instance_type_subscriptions", ["provider_instance_type_id"], name: "index_region_instance_type_sub_on_node_instance_type_id", using: :btree
  add_index "provider_region_instance_type_subscriptions", ["provider_region_id"], name: "index_region_instance_type_sub_on_provider_region_id", using: :btree

  create_table "provider_region_volume_type_subscriptions", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
    t.uuid     "provider_region_id",                    null: false
    t.uuid     "provider_volume_type_id",               null: false
  end

  add_index "provider_region_volume_type_subscriptions", ["provider_region_id"], name: "index_region_volume_type_sub_on_provider_region_id", using: :btree
  add_index "provider_region_volume_type_subscriptions", ["provider_volume_type_id"], name: "index_region_volume_type_sub_on_volume_type_id", using: :btree

  create_table "provider_regions", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                precision: 6
    t.datetime "updated_at",                precision: 6
    t.uuid     "account_id",                                              null: false
    t.uuid     "provider_id",                                             null: false
    t.string   "name",          limit: 255,                               null: false
    t.string   "description",   limit: 255,               default: "",    null: false
    t.text     "details",                                 default: "",    null: false
    t.boolean  "enabled",                                 default: true,  null: false
    t.boolean  "public",                                  default: false, null: false
    t.string   "endpoint_url",  limit: 255,               default: "",    null: false
    t.string   "kernel_image",  limit: 255
    t.string   "machine_image", limit: 255
    t.string   "ramdisk_image", limit: 255
    t.string   "region",        limit: 255
    t.string   "capabilities",  limit: 255,               default: "[]",  null: false
  end

  add_index "provider_regions", ["account_id"], name: "index_provider_regions_on_account_id", using: :btree

  create_table "provider_volume_members", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                     precision: 6
    t.datetime "updated_at",                     precision: 6
    t.uuid     "provider_volume_id",                                        null: false
    t.string   "entity",             limit: 255,               default: "", null: false
    t.string   "name",               limit: 255,                            null: false
    t.string   "description",        limit: 255,               default: "", null: false
    t.string   "device",             limit: 255,               default: "", null: false
    t.string   "status",             limit: 255,                            null: false
    t.uuid     "account_id"
  end

  add_index "provider_volume_members", ["account_id"], name: "index_provider_volume_members_on_account_id", using: :btree
  add_index "provider_volume_members", ["provider_volume_id"], name: "index_provider_volume_members_on_provider_volume_id", using: :btree

  create_table "provider_volume_snapshots", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                     precision: 6
    t.datetime "updated_at",                     precision: 6
    t.uuid     "provider_volume_id",                                        null: false
    t.string   "entity",             limit: 255,               default: "", null: false
    t.string   "name",               limit: 255,                            null: false
    t.string   "description",        limit: 255,               default: "", null: false
    t.string   "status",             limit: 255,                            null: false
  end

  add_index "provider_volume_snapshots", ["provider_volume_id"], name: "index_provider_volume_snapshots_on_provider_volume_id", using: :btree

  create_table "provider_volume_types", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                  precision: 6
    t.datetime "updated_at",                  precision: 6
    t.uuid     "account_id",                                                null: false
    t.uuid     "mount_script_id",                                           null: false
    t.string   "name",            limit: 255,                               null: false
    t.string   "description",     limit: 255,               default: "",    null: false
    t.text     "details",                                   default: "",    null: false
    t.text     "options",                                   default: "{}",  null: false
    t.boolean  "enabled",                                   default: false, null: false
    t.boolean  "public",                                    default: false, null: false
  end

  add_index "provider_volume_types", ["account_id"], name: "index_provider_volume_types_on_account_id", using: :btree

  create_table "provider_volumes", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                          precision: 6
    t.datetime "updated_at",                          precision: 6
    t.uuid     "account_id",                                                        null: false
    t.uuid     "active_instance_id"
    t.uuid     "node_instance_id"
    t.uuid     "node_module_id"
    t.uuid     "mount_script_id"
    t.uuid     "provider_region_id",                                                null: false
    t.uuid     "provider_volume_type_id",                                           null: false
    t.string   "name",                    limit: 255,                               null: false
    t.string   "description",             limit: 255,               default: "",    null: false
    t.text     "details",                                           default: "",    null: false
    t.string   "mount_point",             limit: 255,               default: "",    null: false
    t.text     "options",                                           default: "{}",  null: false
    t.string   "status",                  limit: 255,                               null: false
    t.boolean  "custom_mount_script",                               default: false, null: false
    t.boolean  "mounted",                                           default: false, null: false
    t.boolean  "raid",                                              default: false, null: false
    t.integer  "raid_level",                                        default: 0,     null: false
    t.integer  "size",                                              default: 1,     null: false
    t.integer  "used",                    limit: 8,                 default: 0,     null: false
    t.boolean  "enabled",                                           default: true,  null: false
  end

  add_index "provider_volumes", ["account_id"], name: "index_provider_volumes_on_account_id", using: :btree

  create_table "providers", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
    t.string   "name",        limit: 255,                               null: false
    t.string   "description", limit: 255,               default: "",    null: false
    t.text     "details",                               default: "",    null: false
    t.boolean  "enabled",                               default: true,  null: false
    t.boolean  "public",                                default: false, null: false
    t.string   "variety",     limit: 255,               default: "aws", null: false
    t.uuid     "account_id"
  end

  add_index "providers", ["account_id"], name: "index_providers_on_account_id", using: :btree

  create_table "puppet_modules", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                    precision: 6
    t.datetime "updated_at",                    precision: 6
    t.uuid     "account_id",                                                  null: false
    t.string   "name",              limit: 255,                               null: false
    t.string   "description",       limit: 255,               default: "",    null: false
    t.text     "details",                                     default: "",    null: false
    t.string   "data_file_name",    limit: 255
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size"
    t.datetime "data_updated_at",               precision: 6
    t.string   "data_checksum",     limit: 255,               default: "",    null: false
    t.boolean  "enabled",                                     default: true,  null: false
    t.boolean  "public",                                      default: false, null: false
  end

  add_index "puppet_modules", ["name"], name: "index_puppet_modules_on_name", using: :btree

  create_table "puppet_resources", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                   precision: 6
    t.datetime "updated_at",                   precision: 6
    t.uuid     "puppet_module_id",                                          null: false
    t.string   "name",             limit: 255,                              null: false
    t.string   "description",      limit: 255,               default: "",   null: false
    t.text     "data",                                       default: "",   null: false
    t.text     "details",                                    default: "",   null: false
    t.string   "path",             limit: 255,               default: "",   null: false
    t.boolean  "enabled",                                    default: true, null: false
  end

  add_index "puppet_resources", ["name"], name: "index_puppet_resources_on_name", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v1()", force: :cascade do |t|
    t.datetime "created_at",                         precision: 6
    t.datetime "updated_at",                         precision: 6
    t.uuid     "account_id"
    t.string   "email",                  limit: 255,               default: "",   null: false
    t.string   "encrypted_password",                               default: "",   null: false
    t.integer  "failed_attempts",                                  default: 0,    null: false
    t.string   "locale",                 limit: 255,                              null: false
    t.string   "name",                   limit: 255,                              null: false
    t.integer  "roles_mask",                                       default: 0,    null: false
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at",                       precision: 6
    t.datetime "confirmation_sent_at",               precision: 6
    t.string   "unconfirmed_email",      limit: 255
    t.datetime "reset_password_sent_at",             precision: 6
    t.string   "reset_password_token",   limit: 255
    t.datetime "remember_created_at",                precision: 6
    t.integer  "sign_in_count",                                    default: 0,    null: false
    t.datetime "current_sign_in_at",                 precision: 6
    t.datetime "last_sign_in_at",                    precision: 6
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at",                          precision: 6
    t.text     "preferences",                                      default: "{}", null: false
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
