class NodesController < ApplicationController
  load_resource except: [:create, :new]
  authorize_resource

  before_action { add_breadcrumb @node if @node.present? }
  before_action :check_node_limit, only: [:create, :new]
  before_action :load_module_control_objects, only: [:control_node, :show]
  before_action :load_objects, except: [:index]

  respond_to :html

  def index
    @search = @nodes.search(params[:q])
    @nodes = @search.result.paginate(page: params[:page], per_page: params[:per_page])
    respond_with @nodes
  end

  def show
    @details = @node.details
    respond_with @node
  end

  def new
    @node = Node.new(agent: @current_account.agent)
    respond_with @node
  end

  def create
    @node = Node.create(node_params.merge({ account_id: @current_account.id }))
    respond_with @node
  end

  def update
    @node.update_attributes(node_params)
    respond_with @node
  end

  def destroy
    @node.destroy
    respond_with @node
  end

  def control_node
    @operation = params[:operation]
    @refresh_node_instances = %w[refresh_all refresh_node_instances].include?(@operation)
    @refresh_node_modules = %w[refresh_all refresh_node_modules].include?(@operation)
    sanitized_operation = "do_#{@operation}".gsub(/\W/, '').downcase
    if can?(:update, @node)
      @node_module = NodeModule.accessible_by(@current_ability, :use).find_by(id: params[:node_module_id]) if params[:node_module_id]
      @node_instance = @node.node_instances.find_by(id: params[:node_instance_id]) if params[:node_instance_id]
      @node_instance ||= @node_module && @node_module.node_instance.present? ? @node_module.node_instance : @node.primary_instance
      @provider_volume = @node.provider_volumes.find_by(id: params[:provider_volume_id]) if params[:provider_volume_id]
      self.send(sanitized_operation) if self.respond_to?(sanitized_operation)
      @node_module = @node_module.node_module_subscription ? @node_module.node_module_subscription.node_module : @node_module if @node_module
    end
  end

  def download_image
    @node_instance = @node.node_instances.find_by(id: params[:node_instance_id])
    if @node_instance && @node_instance.image_file_size
      send_file(@node_instance.image.path, type: 'application/octet-stream', filename: @node_instance.download_file_name)
    else
      redirect_to node_path(@node)
    end
  end

  def update_provider_items
  end

  def do_instance_create_image
    if @node_instance && params[:image_format]
      image_format = params[:image_format]
      @node_instance.operations.where(command: 'create_image').destroy_all
      operation = @node_instance.operations.build(account: @current_account,
                                                  command: 'create_image',
                                                  description: I18n.t('nodes.control_node.instance_create_image.description',
                                                                      node_instance: @node_instance.name,
                                                                      image_format: image_format.upcase),
                                                  exclusive: true,
                                                  options: { async: true, image_format: image_format })
      if @node.enabled? && operation.save
        flash[:notice] = I18n.t('flash.nodes.control_node.instance_create_image.notice',
                                node_instance: @node_instance.name,
                                image_format: image_format)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.instance_create_image.alert')
      end
    end
  end

  def do_instance_public_ip_associate
    if @node_instance
      operation = @node_instance.operations.build(account: @current_account,
                                                  command: 'public_ip_associate',
                                                  description: I18n.t('nodes.control_node.instance_public_ip_associate.description',
                                                                      node_instance: @node_instance.name),
                                                  exclusive: true,
                                                  options: { async: true })
      if @node.enabled? && operation.save
        flash[:notice] = I18n.t('flash.nodes.control_node.instance_public_ip_associate.notice',
                                node_instance: @node_instance.name)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.instance_public_ip_associate.alert')
      end
    end
  end

  def do_instance_public_ip_disassociate
    if @node_instance
      operation = @node_instance.operations.build(account: @current_account,
                                                  command: 'public_ip_disassociate',
                                                  description: I18n.t('nodes.control_node.instance_public_ip_disassociate.description',
                                                                      node_instance: @node_instance.name),
                                                  exclusive: true,
                                                  options: { async: true })
      if @node.enabled? && operation.save
        flash[:notice] = I18n.t('flash.nodes.control_node.instance_public_ip_disassociate.notice',
                                node_instance: @node_instance.name)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.instance_public_ip_disassociate.alert')
      end
    end
  end

  def do_instance_exec
    if @node_instance
      exec = params[:exec]
      operation = @node_instance.operations.build(account: @current_account,
                                                  command: 'exec',
                                                  description: I18n.t('nodes.control_node.instance_exec.description',
                                                                      command: exec,
                                                                      node_instance: @node_instance.name),
                                                  exclusive: true,
                                                  options: { async: true, exec: exec })
      if @node.enabled? && operation.save
        flash[:notice] = I18n.t('flash.nodes.control_node.instance_exec.notice',
                                command: exec,
                                node_instance: @node_instance)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.instance_exec.alert',
                               command: exec,
                               node_instance: @node_instance)
      end
    end
  end

  def do_instance_reset_key
    if @node_instance
      @node_instance.reset_key
      if @node_instance.save
        flash[:notice] = I18n.t('flash.nodes.control_node.instance_reset_key.notice',
                                node_instance: @node_instance)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.instance_reset_key.alert',
                               node_instance: @node_instance)
      end
    end
  end

  def do_instance_reboot
    if @node_instance
      operation = @node_instance.operations.build(account: @current_account,
                                                  command: 'reboot',
                                                  description: I18n.t('nodes.control_node.instance_reboot.description',
                                                                      node_instance: @node_instance.name),
                                                  exclusive: true,
                                                  options: { async: true })
      if @node.enabled? && operation.save
        flash[:notice] = I18n.t('flash.nodes.control_node.instance_reboot.notice',
                                node_instance: @node_instance)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.instance_reboot.alert',
                               node_instance: @node_instance)
      end
    end
  end

  def do_instance_set_primary
    if @node_instance
      @node.primary_instance = @node_instance
      @refresh_node_instances = true
      if @node.enabled? && @node.save
        flash[:notice] = I18n.t('flash.nodes.control_node.instance_set_primary.notice',
                                node_instance: @node_instance)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.instance_set_primary.alert',
                               node_instance: @node_instance)
      end
    end
  end

  def do_instance_start
    if @node_instance
      operation = @node_instance.operations.build(account: @current_account,
                                                  command: 'start',
                                                  description: I18n.t('nodes.control_node.instance_start.description',
                                                                      node_instance: @node_instance.name),
                                                  exclusive: true,
                                                  options: { async: true })
      if @node.enabled? && operation.save
        flash[:notice] = I18n.t('flash.nodes.control_node.instance_start.notice',
                                node_instance: @node_instance)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.instance_start.alert',
                               node_instance: @node_instance)
      end
    end
  end

  def do_instance_stop
    if @node_instance
      operation = @node_instance.operations.build(account: @current_account,
                                                  command: 'stop',
                                                  description: I18n.t('nodes.control_node.instance_stop.description',
                                                                      node_instance: @node_instance.name),
                                                  exclusive: true,
                                                  options: { async: true })
      if @node.enabled? && operation.save
        flash[:notice] = I18n.t('flash.nodes.control_node.instance_stop.notice',
                                node_instance: @node_instance)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.instance_stop.alert',
                               node_instance: @node_instance)
      end
    end
  end

  def do_instance_terminate
    if @node_instance
      operation = @node_instance.operations.build(account: @current_account,
                                                  command: 'terminate',
                                                  description: I18n.t('nodes.control_node.instance_terminate.description',
                                                                      node_instance: @node_instance.name),
                                                  exclusive: true,
                                                  options: { async: true })
      if @node.enabled? && operation.save
        flash[:notice] = I18n.t('flash.nodes.control_node.instance_terminate.notice',
                                node_instance: @node_instance.name)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.instance_terminate.alert')
      end
    end
  end

  def do_operation_unschedule_id
    operation = @current_account.operations.find_by(id: params[:operation_id])
    if operation && operation.destroy
      flash[:notice] = I18n.t('flash.nodes.control_node.operation_unschedule_id.notice')
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.operation_unschedule_id.alert')
    end
  end

  def do_module_create_dependency
    logger.info "\n\n\nNODE MODULE: #{@node_module}\n\n\n"
    if (node_module_subscription = @node.node_module_subscriptions.find_by(id: params[:node_module_subscription_id]))
      @node_module = node_module_subscription.node_module
    end
    if node_module_subscription && node_module_subscription.create_dependant_module!(@node.node_instances.find_by(id: params[:node_instance_id]))
      flash[:notice] = I18n.t('flash.nodes.control_node.module_create_dependency.notice',
                              node_module: @node_module.name)
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.module_create_dependency.alert')
    end
  end

  def do_module_subscribe
    if @node_module && !@node.node_modules.include?(@node_module)
      if @node.node_modules << @node_module
        flash[:notice] = I18n.t('flash.nodes.control_node.module_subscribe.notice',
                                node_module: @node_module)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.module_subscribe.alert',
                               node_module: @node_module)
      end
    end
  end

  def do_module_unsubscribe
    if @node_module && @node.node_modules.include?(@node_module)
      if @node.node_modules.destroy(@node_module)
        flash[:notice] = I18n.t('flash.nodes.control_node.module_unsubscribe.notice',
                                node_module: @node_module)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.module_unsubscribe.alert',
                               node_module: @node_module)
      end
    end
  end

  def do_module_build
    if can?(:update, @node_module) && @node_instance
      operation = @node_module.operations.build(account: @current_account,
                                                command: 'build',
                                                description: I18n.t('nodes.control_node.module_build.description',
                                                                    node_module: @node_module.name,
                                                                    node_instance: @node_instance.name),
                                                exclusive: true,
                                                options: { node_instance_id: @node_instance.id })
      if @node.enabled? && operation.save
        flash[:notice] = I18n.t('flash.nodes.control_node.module_build.notice',
                                node_module: @node_module,
                                node_instance: @node_instance.name)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.module_build.alert',
                               node_module: @node_module,
                               node_instance: @node_instance.name)
      end
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.module_build.alert_no_instance',
                             node_module: @node_module)
    end
  end

  def do_module_commit
    if can?(:update, @node_module) && @node_instance
      operation = @node_module.operations.build(account: @current_account,
                                                command: 'commit',
                                                description: I18n.t('nodes.control_node.module_commit.description',
                                                                    node_module: @node_module.name,
                                                                    node_instance: @node_instance.name),
                                                exclusive: true,
                                                options: { async: true, node_instance_id: @node_instance.id })
      if @node.enabled? && operation.save
        flash[:notice] = I18n.t('flash.nodes.control_node.module_commit.notice',
                                node_module: @node_module,
                                node_instance: @node_instance.name)
      else
        flash[:alert] = I18n.t('flash.nodes.control_node.module_commit.alert',
                               node_module: @node_module,
                               node_instance: @node_instance.name)
      end
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.module_commit.alert_no_instance',
                             node_module: @node_module)
    end
  end

  def do_module_delete
    if can?(:update, @node_module) && @node_module.version_delete!(params[:version].to_i)
      flash[:notice] = I18n.t('flash.nodes.control_node.module_delete.notice',
                              node_module: @node_module,
                              version: params[:version].to_i)
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.module_delete.alert',
                             node_module: @node_module,
                             version: params[:version].to_i)
    end
  end

  def do_module_destroy
    if can?(:update, @node_module) && @node_module.destroy
      flash[:notice] = I18n.t('flash.nodes.control_node.module_destroy.notice',
                              node_module: @node_module)
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.module_destroy.alert',
                             node_module: @node_module)
    end
  end

  def do_module_purge
    if can?(:update, @node_module) && @node_module.version_purge!(params[:version].to_i)
      flash[:notice] = I18n.t('flash.nodes.control_node.module_purge.notice',
                              node_module: @node_module,
                              version: params[:version].to_i)
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.module_purge.alert',
                             node_module: @node_module,
                             version: params[:version].to_i)
    end
  end

  def do_module_restore
    if can?(:update, @node_module) && @node_module.version_restore!(params[:version].to_i)
      flash[:notice] = I18n.t('flash.nodes.control_node.module_restore.notice',
                              node_module: @node_module,
                              version: params[:version].to_i,
                              new_version: @node_module.version)
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.module_restore.alert',
                             node_module: @node_module,
                             version: params[:version].to_i)
    end
  end

  def do_module_update
    if @node_module && can?(:update, @node_module)
      if (subscription = @node.node_module_subscriptions.find_by(node_module_id: params[:node_module_id]))
        subscription.enabled = params[:enabled] if params[:enabled]
        node_module_copy_path = @available_node_module_copy_paths.find_by(id: params[:node_module_copy_path_id])
        subscription.node_module_copy_path = node_module_copy_path
        subscription.save
      end
    end
    if @node_module.save
      flash[:notice] = I18n.t('flash.nodes.control_node.module_update.notice',
                              node_module: @node_module)
    else
      flash[:notice] = I18n.t('flash.nodes.control_node.module_update.notice',
                              node_module: @node_module)
    end
  end

  def do_create_cloud_instance
    options = { async: true, variety: 'cloud' }
    options[:provider_connection_id]        = @provider_connection.try(:id)
    options[:provider_region_id]            = @provider_region.try(:id)
    options[:provider_availability_zone_id] = @provider_availability_zone.try(:id)
    options[:provider_availability_zone]    = @provider_availability_zone.try(:entity)
    options[:provider_instance_type_id]     = @provider_instance_type.try(:id)
    options[:provider_network_subnet_id]    = @provider_network_subnet.try(:id)
    options[:provider_network_id]           = @provider_network_subnet.provider_network.id if @provider_network_subnet
    operation = @node.operations.build(account: @current_account,
                                       command: 'create_cloud_instance',
                                       description: I18n.t('nodes.control_node.create_cloud_instance.description',
                                                           node: @node.name),
                                       exclusive: true,
                                       options: options)
    if @node.enabled? && operation.save
      flash[:notice] = I18n.t('flash.nodes.control_node.create_cloud_instance.notice',
                              node: @node)
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.create_cloud_instance.alert')
    end
  end

  def do_create_physical_instance
    node_instance = @node.node_instances.build(node_instance_params)
    if @node.enabled? && node_instance.save
      @refresh_node_instances = true
      flash[:notice] = I18n.t('flash.nodes.control_node.create_physical_instance.notice',
                              node: @node)
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.create_physical_instance.alert',
                             node: @node)
    end
  end

  def do_instance_destroy
    if @node.enabled? && @node_instance.physical_variety? && @node_instance.destroy
      @refresh_node_instances = true
      flash[:notice] = I18n.t('flash.nodes.control_node.instance_destroy.notice', node_instance: @node_instance)
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.instance_destroy.alert', node_instance: @node_instance)
    end
  end

  def do_send_ssh_key
    ssh_encryption_key = params[:ssh_encryption_key] if params[:ssh_encryption_key].length == Powernode.config.encryption_key_length && params[:ssh_encryption_key].match(/\A[0-9a-f]*\z/i)
    operation = @node.operations.build(account: @current_account,
                                       command: 'send_ssh_key',
                                       description: I18n.t('nodes.control_node.send_ssh_key.description', node: @node.name),
                                       options: { async: true,
                                                  ssh_encryption_key: ssh_encryption_key,
                                                  recipient: @current_user.email }) if ssh_encryption_key && @node.ssh_key.present?
    if ssh_encryption_key.present? && @node.enabled? && @node.ssh_key.present? && operation.save
      flash[:notice] = I18n.t('flash.nodes.control_node.send_ssh_key.notice', recipient: @current_user.email)
    elsif @node.ssh_key.empty? && @node.enabled?
      flash[:alert] = I18n.t('flash.nodes.control_node.send_ssh_key.alert_no_ssh_key')
    elsif !ssh_encryption_key && @node.enabled?
      flash[:alert] = I18n.t('flash.nodes.control_node.send_ssh_key.alert_invalid_encryption_key', key_length: Powernode.config.encryption_key_length)
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.send_ssh_key.alert')
    end
  end

  def do_sync_cloud_instances
    operation = @node.operations.build(account: @current_account,
                                       command: 'sync_cloud_instances',
                                       description: I18n.t('nodes.control_node.sync_cloud_instances.description', node: @node.name),
                                       exclusive: true,
                                       scheduled_at: params[:sync_cloud_instances_scheduled_at].present? ? Time.parse(params[:sync_cloud_instances_scheduled_at]) : Time.now,
                                       options: { async: true })
    if @node.enabled? && operation.save
      flash[:notice] = I18n.t('flash.nodes.control_node.sync_cloud_instances.notice')
    else
      flash[:alert] = I18n.t('flash.nodes.control_node.sync_cloud_instances.alert')
    end
  end

  private

  def check_node_limit
    if @current_account.reached_node_limit?
      flash[:alert] = I18n.t('flash.nodes.create.alert_limit_reached')
      redirect_to nodes_path
    end
  end

  def load_module_control_objects
    @available_node_module_categories = @node.node_template.node_module_categories.accessible_by(@current_ability, :use).uniq
    @available_node_modules = @node.node_template.node_modules.accessible_by(@current_ability, :use).subscription_variety
  end

  def load_objects
    @available_agents = Agent.accessible_by(@current_ability, :use)
    @available_node_module_copy_paths = NodeModuleCopyPath.accessible_by(@current_ability, :use)
    @available_node_templates = NodeTemplate.accessible_by(@current_ability, :use)
    @available_utility_scripts = NodeScript.accessible_by(@current_ability, :use).utility_variety
    @available_provider_connections = ProviderConnection.accessible_by(@current_ability, :use)
    if params[:provider_connection_id].present? && (@provider_connection = @available_provider_connections.find_by(id: params[:provider_connection_id]))
      @available_provider_regions = @provider_connection.provider_regions.accessible_by(@current_ability, :use)
      if params[:provider_region_id].present? && (@provider_region = @provider_connection.provider_regions.find_by(id: params[:provider_region_id]))
        @available_provider_availability_zones = @provider_region.provider_availability_zones.accessible_by(@current_ability, :use)
        @available_provider_instance_types = @provider_region.provider_instance_types.accessible_by(@current_ability, :use)
        @provider_instance_type = @provider_region.provider_instance_types.find_by(id: params[:provider_instance_type_id]) if params[:provider_instance_type_id].present?
        if params[:provider_availability_zone_id].present? && (@provider_availability_zone = @provider_region.provider_availability_zones.find_by(id: params[:provider_availability_zone_id]))
          @available_provider_network_subnets = @provider_region.provider_network_subnets.where(provider_availability_zone: @provider_availability_zone).accessible_by(@current_ability, :use)
          @provider_network_subnet = @provider_region.provider_network_subnets.find_by(id: params[:provider_network_subnet_id]) if params[:provider_network_subnet_id].present?
        end
      end
    end
    @available_provider_availability_zones  ||= []
    @available_provider_instance_types      ||= []
    @available_provider_network_subnets     ||= []
    @available_provider_regions             ||= []
  end

  def node_params
    permitted_params = [{ node_mount_point_ids: [] },
                        :agent_id,
                        :allocate_public_ip,
                        :custom_sync_script,
                        :description,
                        :details,
                        :enabled,
                        :name,
                        :node_template_id,
                        :ssh_key,
                        :ssh_key_fingerprint,
                        :sync_script_id,
                        :tmpfs_store]
    params.require(:node).permit(*permitted_params)
  end

  def node_instance_params
    permitted_params = [:address,
                        :description,
                        :name,
                        :private_netboot_enabled,
                        :private_mac_address,
                        :private_ip_static,
                        :private_ip_address,
                        :private_ip_netmask,
                        :private_ip_gateway,
                        :private_ip_device,
                        :private_ip_domain,
                        :private_ip_primary_dns,
                        :private_ip_secondary_dns,
                        :public_ip_address,
                        :variety]
    params.require(:node_instance_params).permit(*permitted_params)
  end
end
