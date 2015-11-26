class NodeInstancesController < ApplicationController
  load_and_authorize_resource

  before_action do
    @breadcrumbs = nil
    add_breadcrumb I18n.t('actions.home'), :root_path
    add_breadcrumb 'Nodes', :nodes_path
    add_breadcrumb @node_instance.node.name, node_path(@node_instance.node)
    add_breadcrumb @node_instance
  end
  before_action :load_objects, except: [:index]

  respond_to :html

  def show
    redirect_to @node_instance.node
  end

  def update
    @node_instance.update_attributes(node_instance_params)
    respond_with @node_instance, location: node_path(@node_instance.node)
  end

  private

  def load_objects
    @available_node_mount_points = NodeMountPoint.accessible_by(@current_ability, :use)
  end

  def node_instance_params
    permitted_params  = [{ node_mount_point_ids: [],
                           pages_attributes: [:id,
                                              :name,
                                              :title,
                                              :_destroy] },
                         :description,
                         :name]
    permitted_params += [:address,
                         :address_full,
                         :key,
                         :latitude,
                         :longitude,
                         :private_ip_address,
                         :private_ip_device,
                         :private_ip_domain,
                         :private_ip_gateway,
                         :private_ip_netmask,
                         :private_ip_primary_dns,
                         :private_ip_secondary_dns,
                         :private_ip_static,
                         :private_mac_address,
                         :private_netboot_updated_at,
                         :private_netboot_enabled,
                         :public_ip_address] if @node_instance.physical_variety?
    params.require(:node_instance).permit(*permitted_params)
  end
end
