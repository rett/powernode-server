module Api
  module AgentV1
    class AgentApiController < ActionController::Base
      before_action :authenticate
      before_action :load_credentials
      before_action :load_objects

      def account_attributes
        { except: [:encryption_key] }
      end

      def accounts
        respond_to do |format|
          if @account
            format.json { render json: @account.as_json(account_attributes) }
          elsif params[:account_id]
            format.json { render nothing: true, status: :not_found }
          else
            format.json { render json: @agent.accounts.as_json(account_attributes) }
          end
        end
      end

      def node_attributes
        { include: [:node_architecture],
          methods: [:admin_user,
                    :agent_id,
                    :dynamic_instance_max_available,
                    :enabled,
                    :init_script_id,
                    :instance_limit,
                    :module_extension,
                    :module_info_extension,
                    :module_update_extension,
                    :proxy_url,
                    :ssh_key] }
      end

      def nodes
        if @node
          if params[:ssh_key] && params[:ssh_key_fingerprint]
            @node.ssh_key = params[:ssh_key]
            @node.ssh_key_fingerprint = params[:ssh_key_fingerprint]
            @node.save
          end
          respond_to do |format|
            format.json { render json: @node.as_json(node_attributes) }
          end
        else
          respond_to do |format|
            if @account
              format.json { render json: @account.nodes.where(agent: @agent).as_json(node_attributes) }
            else
              format.json { render json: Node.accessible_by(@ability, :update).where(agent: @agent).as_json(node_attributes) }
            end
          end
        end
      end

      def node_architectures
        @node_architectures = NodeArchitecture.accessible_by(@ability, :use)
        if params[:node_architecture_id]
          if (@node_architecture = @node_architectures.find_by(id: params[:node_architecture_id]))
            respond_to do |format|
              format.json { render json: @node_architecture.as_json }
            end
          else
            render nothing: true, status: :not_found
          end
        else
          respond_to do |format|
            format.json { render json: @node_architectures.as_json }
          end
        end
      end

      def node_architecture_download
        resource = params[:resource].gsub(/\W/, '')
        node_architecture = NodeArchitecture.accessible_by(@ability, :use).find_by(id: params[:node_architecture_id]) if params[:node_architecture_id]
        if node_architecture && node_architecture.respond_to?(resource) && node_architecture.send(resource).path && File.exist?(node_architecture.send(resource).path)
          send_file(node_architecture.send(resource).path, filename: node_architecture.send("#{resource}_file_name"))
        else
          render nothing: true, status: :not_found
        end
      end

      def node_architecture_upload
        if params[:node_architecture_id] && (node_architecture = NodeArchitecture.accessible_by(@ability, :update).find_by(id: params[:node_architecture_id]))
          case params[:resource]
          when 'image'
            node_architecture.image = params.require(:image)
            if node_architecture.image_file_size > 0 && node_architecture.save
              render nothing: true, status: :ok
            else
              render nothing: true, status: :not_found
            end
          else
            render nothing: true, status: :not_found
          end
        else
          render nothing: true, status: :not_found
        end
      end

      def node_instance_upload
        if @node_instance
          case params[:resource]
          when 'image'
            @node_instance.image = params.require(:image)
            @node_instance.image_format = params.require(:image_format)
            if @node_instance.image_file_size > 0 && @node_instance.save
              render nothing: true, status: :ok
            else
              render nothing: true, status: :not_found
            end
          else
            render nothing: true, status: :not_found
          end
        else
          render nothing: true, status: :not_found
        end
      end

      def node_instance_attributes
        { methods: [:config, :key] }
      end

      def node_instance_permitted_params
        [:image,
         :key,
         :node_id,
         :private_ip_address,
         :private_mac_address,
         :private_netboot_updated_at,
         :private_netboot_enabled,
         :provider_availability_zone_id,
         :provider_connection_id,
         :provider_region_id,
         :provider_instance_type_id,
         :provider_network_subnet_id,
         :public_ip_address,
         :status,
         :started_at,
         :variety]
      end

      def node_instances
        if request.get?
          if @node_instance
            respond_to do |format|
              format.json { render json: @node_instance.as_json(node_instance_attributes) }
            end
          elsif params[:node_instance_id]
            respond_to do |format|
              format.json { head :not_found }
            end
          else
            if @node
              @node_instances = params[:variety] ? @node.node_instances.where(variety: params[:variety]) : @node.node_instances
            else
              @node_instances = params[:variety] ? NodeInstance.accessible_by(@ability, :update).where(variety: params[:variety]) : NodeInstance.accessible_by(@ability, :update)
            end
            respond_to do |format|
              format.json { render json: @node_instances.as_json(node_instance_attributes) }
            end
          end
        elsif request.put?
          if @node_instance
            @node_instance.update_attributes(params.permit(*node_instance_permitted_params))
          elsif request.put?
            params[:id] = params[:node_instance_id]
            @node_instance = NodeInstance.create(params.permit(*(node_instance_permitted_params + [:entity, :id, :name])))
          end
          respond_to do |format|
            format.json { render json: @node_instance.as_json(node_instance_attributes) }
          end
        elsif request.delete?
          @node_instance.destroy
          respond_to do |format|
            format.json { head :ok }
          end
        else
          respond_to do |format|
            format.json { head :not_found }
          end
        end
      end

      def node_module_attributes
        { except:  [:dependency_spec,
                    :file_spec,
                    :mask,
                    :package_spec],
          methods: [:data_file_version,
                    :ready,
                    :uuid_partition] }
      end

      def node_module_permitted_params
        [:data]
      end

      def node_modules
        if params[:node_module_id] && (@node_module = NodeModule.accessible_by(@ability, :use).find_by(id: params[:node_module_id]))
          @node_module = @node_module.scope_to_node_instance(@node_instance) if @node_instance
          if request.get?
            respond_to do |format|
              format.json { render json: @node_module.as_json(node_module_attributes) }
            end
          elsif request.put?
            @node_module.update_attributes(params.permit(*node_module_permitted_params))
            respond_to do |format|
              format.json { render json: @node_module.as_json(node_module_attributes) }
            end
          elsif request.delete?
            @node_module.destroy
            respond_to do |format|
              format.json { head :ok }
            end
          end
        elsif @node_instance
          if request.post?
            @node_module = @node.node_modules.create(params.permit(*node_module_permitted_params))
            respond_to do |format|
              format.json { render json: @node_module.as_json(node_module_attributes) }
            end
          else
            @node_modules = params[:variety] ? @node_instance.node_modules_with_dependencies.select { |m| m.variety == params[:variety] } : @node_instance.node_modules_with_dependencies
            respond_to do |format|
              format.json { render json: @node_modules.as_json(node_module_attributes) }
            end
          end
        else
          respond_to do |format|
            format.json { render json: NodeModule.accessible_by(@ability, :use).as_json(node_module_attributes) }
          end
        end
      end

      def node_module_download
        if params[:node_module_id] && (@node_module = NodeModule.accessible_by(@ability, :use).find_by(id: params[:node_module_id]))
          case params[:resource]
          when 'data'
            if @node_module.ready?
              send_file(@node_module.data.path, type: 'application/octet-stream', filename: @node_module.data_file_name)
            else
              render nothing: true, status: :not_found
            end
          when 'info'
            render text: @node_module.info
          when 'file_spec'
            render text: @node_module.file_spec
          when 'package_spec'
            render text: @node_module.package_spec
          when 'rsync_spec'
            render text: @node_module.rsync_spec
          else
            render nothing: true, status: :not_found
          end
        else
          render nothing: true, status: :not_found
        end
      end

      def node_module_upload
        @node_module = NodeModule.accessible_by(@ability, :use).find_by(id: params[:node_module_id]) if params[:node_module_id]
        case params[:resource]
        when 'data'
          @node_module.data = params.require(:data)
          if @node_module.data_file_size > 0 && @node_module.save
            render nothing: true, status: :ok
          else
            render nothing: true, status: :not_found
          end
        when 'file_spec'
          @node_module.file_spec = params.require(:file_spec)
          if @node_module.save
            render nothing: true, status: :ok
          else
            render nothing: true, status: :not_found
          end
        end
      end

      def node_script_download
        if params[:node_script_id] && (@node_script = NodeScript.accessible_by(@ability, :use).find_by(id: params[:node_script_id]))
          render text: @node_script.data
        else
          render nothing: true, status: :not_found
        end
      end

      def node_template_attributes
        { include: [:node_architecture] }
      end

      def node_templates
        if params[:node_template_id] && (@node_template = NodeTemplate.accessible_by(@ability, :use).find_by(id: params[:node_template_id]))
          respond_to do |format|
            format.json { render json: @node_template.as_json(node_template_attributes) }
          end
        else
          render nothing: true, status: :not_found
        end
      end

      def operation_attributes
        { except: [:events] }
      end

      def operation_permitted_params
        [:progress, :status]
      end

      def operations
        @operation = Operation.accessible_by(@ability, :update).find_by(id: params[:operation_id]) if params[:operation_id]
        if request.put? && @operation
          @operation.events += params[:events].select { |e| !@operation.events.include?(e) } if params[:events].present?
          @operation.update_attributes(params.permit(*operation_permitted_params))
          @operation.save
          respond_to do |format|
            format.json { render json: @operation.as_json(operation_attributes) }
          end
        elsif @operation
          respond_to do |format|
            format.json { render json: @operation.as_json(operation_attributes) }
          end
        else
          if params[:operable_type]
            operable_type = params[:operable_type].gsub(/[\W]/,'').classify.safe_constantize
            @operations = operable_type.find_by(id: params[:operable_id]).operations
          elsif @account
            @operations = @account.operations
          else
            @operations = Operation.accessible_by(@ability, :update)
          end
          respond_to do |format|
            format.json { render json: @operations.as_json(operation_attributes) }
          end
        end
      end

      def provider_availability_zones
        @provider_availability_zones = ProviderAvailabilityZone.accessible_by(@ability, :use)
        if params[:provider_availability_zone_id]
          if (@provider_availability_zone = @provider_availability_zones.find_by(id: params[:provider_availability_zone_id]))
            respond_to do |format|
              format.json { render json: @provider_availability_zone.as_json }
            end
          else
            render nothing: true, status: :not_found
          end
        else
          respond_to do |format|
            format.json { render json: @provider_availability_zones.as_json }
          end
        end
      end

      def provider_connection_attributes
        { except:  [:encrpted_secret_key],
          include: [:provider_regions],
          methods: [:secret_key, :variety] }
      end

      def provider_connections
        @provider_connections = ProviderConnection.accessible_by(@ability, :use)
        if params[:provider_connection_id]
          if (@provider_connection = @provider_connections.find_by(id: params[:provider_connection_id]))
            respond_to do |format|
              format.json { render json: @provider_connection.as_json(provider_connection_attributes) }
            end
          else
            render nothing: true, status: :not_found
          end
        else
          respond_to do |format|
            format.json { render json: @provider_connections.as_json(provider_connection_attributes) }
          end
        end
      end

      def provider_instance_types
        @provider_instance_types = ProviderInstanceType.accessible_by(@ability, :use)
        if params[:provider_instance_type_id]
          if (@provider_instance_type = @provider_instance_types.find_by(id: params[:provider_instance_type_id]))
            respond_to do |format|
              format.json { render json: @provider_instance_type.as_json }
            end
          else
            render nothing: true, status: :not_found
          end
        else
          respond_to do |format|
            format.json { render json: @provider_instance_types.as_json }
          end
        end
      end

      def provider_networks
        @provider_networks = ProviderNetwork.accessible_by(@ability, :use)
        if params[:provider_network_id]
          if (@provider_network = @provider_networks.find_by(id: params[:provider_network_id]))
            respond_to do |format|
              format.json { render json: @provider_network.as_json }
            end
          else
            render nothing: true, status: :not_found
          end
        else
          respond_to do |format|
            format.json { render json: @provider_networks.as_json }
          end
        end
      end

      def provider_network_subnets
        @provider_network_subnets = ProviderNetworkSubnet.accessible_by(@ability, :use)
        if params[:provider_network_subnet_id]
          if (@provider_network_subnet = @provider_network_subnets.find_by(id: params[:provider_network_subnet_id]))
            respond_to do |format|
              format.json { render json: @provider_network_subnet.as_json }
            end
          else
            render nothing: true, status: :not_found
          end
        else
          respond_to do |format|
            format.json { render json: @provider_network_subnets.as_json }
          end
        end
      end

      def provider_region_attributes
        { include: [:provider_instance_types] }
      end

      def provider_regions
        @provider_regions = ProviderRegion.accessible_by(@ability, :use)
        if params[:provider_region_id]
          if (@provider_region = @provider_regions.find_by(id: params[:provider_region_id]))
            respond_to do |format|
              format.json { render json: @provider_region.as_json }
            end
          else
            render nothing: true, status: :not_found
          end
        else
          respond_to do |format|
            format.json { render json: @provider_regions.as_json(provider_region_attributes) }
          end
        end
      end

      def provider_volume_attributes
        { include: [:provider_volume_type],
          methods: [:actual_size]}
      end

      def provider_volume_permitted_params
        [:active_instance_id,
         :status]
      end

      def provider_volumes
        if params[:provider_volume_id] && (@provider_volume = ProviderVolume.accessible_by(@ability, :use).find_by(id: params[:provider_volume_id]) )
          if request.put?
            @provider_volume.update_attributes(params.permit(*provider_volume_permitted_params))
            respond_to do |format|
              format.json { render json: @provider_volume.as_json(volume_attributes) }
            end
          elsif request.get?
            respond_to do |format|
              format.json { render json: @provider_volume.as_json(volume_attributes) }
            end
          else
            render nothing: true, status: :not_found
          end
        elsif request.get?
          respond_to do |format|
            format.json { render json: ProviderVolume.accessible_by(@ability, :use).as_json(provider_volume_attributes) }
          end
        else
          render nothing: true, status: :not_found
        end
      end

      def provider_volume_member_attributes
        { methods: [:name] }
      end

      def provider_volume_member_permitted_params
        [:device,
         :entity,
         :name,
         :status,
         :provider_volume_id]
      end

      def provider_volume_members
        if params[:provider_volume_member_id] && (@provider_volume_member = ProviderVolumeMember.accessible_by(@ability, :use).find_by(id: params[:provider_volume_member_id]))
          @provider_volume_member.update_attributes(params.permit(*provider_volume_member_permitted_params)) if request.put?
          respond_to do |format|
            format.json { render json: @provider_volume_member.as_json(provider_volume_member_attributes) }
          end
        elsif @provider_volume
          if request.get?
            respond_to do |format|
              format.json { render json: @provider_volume.provider_volume_members.as_json(provider_volume_member_attributes) }
            end
          elsif request.post?
            @provider_volume_member = ProviderVolumeMember.create(params.permit(*provider_volume_member_permitted_params))
            respond_to do |format|
              format.json { render json: @provider_volume_member.as_json(provider_volume_member_attributes) }
            end
          end
        else
          render nothing: true, status: :not_found
        end
      end

      def provider_volume_snapshot_permitted_params
        [:entity,
         :name,
         :status,
         :provider_volume_id]
      end

      def provider_volume_snapshots
        if params[:provider_volume_snapshot_id] && (@provider_volume_snapshot = VolumeSnapshot.accessible_by(@ability, :update).find_by(id: params[:provider_volume_snapshot_id]))
          @provider_volume_snapshot.update_attributes(params.permit(*provider_volume_snapshot_permitted_params)) if request.put?
          respond_to do |format|
            format.json { render json: @provider_volume_snapshot.as_json }
          end
        elsif @provider_volume
          if request.get?
            respond_to do |format|
              format.json { render json: @provider_volume.volume_snapshots.as_json }
            end
          elsif request.post?
            @provider_volume_snapshot = ProviderVolumeSnapshot.create(params.permit(*provider_volume_snapshot_permitted_params))
            respond_to do |format|
              format.json { render json: @provider_volume_snapshot.as_json }
            end
          end
        else
          render nothing: true, status: :not_found
        end
      end

      def not_found
        render nothing: true, status: :not_found
      end

      private

      def authenticate
        authenticate_or_request_with_http_basic(Powernode.config.http_realm) do |id, key|
          (@agent = Agent.find_by(id: id)) && @agent.authenticate(key)
        end
        warden.custom_failure! if performed?
      end

      def default_serializer_options
        { root: false }
      end

      def load_credentials
        @account = @agent.accounts.find_by(id: params[:account_id]) if params[:account_id]
        @ability = Ability.new(agent: @agent)
      end

      def load_objects
        @node_instance = NodeInstance.accessible_by(@ability, :update).find_by(id: params[:node_instance_id]) if params[:node_instance_id]
        @node = Node.accessible_by(@ability, :update).find_by(id: params[:node_id]) if params[:node_id]
        @node ||= @node_instance.node if @node_instance
      end
    end
  end
end
