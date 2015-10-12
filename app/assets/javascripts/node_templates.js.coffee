$(document).bind 'edit_node_templates.load', (e, obj) =>
  $("#node_template_node_platform_id")
    .change ->
      node_platform = $("select#node_template_node_platform_id :selected").val()
      update_platform_items_url = $("form.node_template").select(".node_template").attr("action") + "/update_platform_items/#{node_platform}"
      jQuery.ajax(url: update_platform_items_url, dataType: 'script')
