module NodesHelper
  def control_node_button(operation, label: nil, options: nil, html_options: nil)
    label ||= I18n.t("nodes.control_node.#{operation.to_s}.label")
    button_to(label,
              { action: 'control_node', operation: operation }.merge(options || {}),
              { remote: true }.merge(html_options || {}))
  end

  def refresh_button(object_type, node_instance_id: nil, node_module_id: nil, &block)
    link_options = { action: 'control_node', remote: true }
    if object_type == :node_instances
      link_options.merge!({ node_instance_id: node_instance_id }) if node_instance_id
      link_options.merge!({ operation: 'refresh_node_instances' }) unless node_instance_id
    elsif object_type == :node_modules
      link_options.merge!(node_module_id ? { node_module_id: node_module_id } : { operation: 'refresh_node_modules' })
      link_options.merge!({ operation: 'refresh_node_modules' }) unless node_module_id
    end
    link_to(link_options) { capture(&block) }
  end
end
