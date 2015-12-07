module Api
  module NodeV1
    class NodeApiController < ActionController::Base
      before_action :authenticate
      before_action :load_credentials

      def node_instance_config
        respond_to do |format|
          format.text { send_data @node_instance.config }
        end
      end

      def node_instance_authorized_keys
        respond_to do |format|
          format.text { render 'authorized_keys' }
        end
      end

      def node_instance_host_keys
        respond_to do |format|
          format.text { render 'host_keys' }
        end
      end

      def node_modules
        @node_modules = @node_instance.node_modules
        @node_modules += @node_instance.node_modules_with_dependencies.select { |m| !m.provisional }
        @node_modules += @node_instance.node_modules_with_dependencies.select { |m| m.provisional } if params[:provisional] == 'true'
        @node_modules.uniq!
        @node_modules.delete_if { |m| !m.ready? }
        @node_modules.delete_if { |m| !@node.node_module_subscription(m) && m.node_module_subscription && !m.node_module_subscription.enabled? }
        @node_modules.delete_if { |m| @node.node_module_subscription(m) && !@node.node_module_subscription(m).enabled? }
        @node_modules.delete_if { |m| m.node_instance && m.node_instance != @node_instance }
        respond_to do |format|
          format.csv do
            csv_string = CSV.generate({ force_quotes: true }) do |csv|
              @node_modules.each do |node_module|
                csv << [node_module.status,
                        node_module.id,
                        node_module.data_file_version,
                        node_module.data_checksum] if node_module.data_checksum
              end
            end
            send_data csv_string, type: 'text/csv'
          end
        end
      end

      def node_module
        if (@node_module = @node_instance.node_modules_with_dependencies.select { |m| m.id == params[:node_module_id] }.first) &&
            (@node_instance && @node_module.node_instance ? @node_module.node_instance == @node_instance : true)
          respond_to do |format|
            format.html do
              if @node_module.ready?
                send_file(@node_module.data.path, type: 'application/octet-stream', filename: @node_module.data_file_name)
              else
                render nothing: true, status: :not_found
              end
            end
          end
        else
          render nothing: true, status: :not_found
        end
      end

      def node_module_resource
        @node_module = @node_instance.node_modules_with_dependencies.select { |m| m.id == params[:node_module_id] }.first
        if @node_module
          case params[:resource]
          when 'info'
            render text: @node_module.scope_to_node_instance(@node_instance).info
          when 'rsync_spec'
            render text: @node_module.scope_to_node_instance(@node_instance).rsync_spec
          when 'package_spec'
            render text: @node_module.package_spec_text
          else
            render nothing: true, status: :not_found
          end
        else
          render nothing: true, status: :not_found
        end
      end

      def node_mount_points
        respond_to do |format|
          format.csv do
            csv_string = CSV.generate({ force_quotes: true }) do |csv|
              @node_instance.node_mount_points.sort.each do |node_mount_point|
                csv << [node_mount_point.name,
                        node_mount_point.description,
                        node_mount_point.device,
                        node_mount_point.path,
                        node_mount_point.parameters,
                        node_mount_point.mount_script_id,
                        node_mount_point.node_module_id]
              end
            end
            send_data csv_string, type: 'text/csv'
          end
        end
      end

      def node_script
        if params[:node_script_id] =~ /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/
          node_script = NodeScript.accessible_by(@ability, :use).find_by(id: params[:node_script_id])
        else
          node_script = NodeScript.accessible_by(@ability, :use).find_by(name: params[:node_script_id])
        end
        if node_script
          respond_to do |format|
            format.text { send_data node_script.data.gsub(/\r\n?/, "\n") }
          end
        else
          render nothing: true, status: :unauthorized
        end
      end

      def not_found
        render nothing: true, status: :not_found
      end

      def puppet_resources
        respond_to do |format|
          format.text { render 'puppet_resources' }
        end
      end

      def status
        respond_to do |format|
          format.text { send_data @node_instance.id }
        end
      end

      private

      def authenticate
        authenticate_or_request_with_http_basic(Powernode.config.http_realm) do |id, key|
          if (@node_instance = NodeInstance.find_by(id: id))
            @node = @node_instance.node
            @node_instance.authenticate(key)
          else
            false
          end
        end
        warden.custom_failure! if performed?
      end

      def load_credentials
        @ability = Ability.new(user: @node.account.owner)
      end
    end
  end
end
