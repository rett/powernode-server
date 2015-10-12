$(document).bind 'edit_node_module_categories.load', (e, obj) =>
  config_category_inputs = $('#config_category_inputs')
  config_category = $('#node_module_category_config_category_id')
  instance_category = $('#node_module_category_instance_category_id')
  variety = $('#node_module_category_variety')
  variety_input = $('#node_module_category_variety_input')
  if variety.val() != 'subscription'
    config_category_inputs.hide()
    config_category.attr('disabled', 'disabled')
    instance_category.attr('disabled', 'disabled')
  if variety.is(':disabled')
    variety_input.hide()
  variety
    .change ->
      if variety.val() == 'subscription'
        config_category_inputs.show('fadeIn')
        config_category.multiselect('enable')
        instance_category.multiselect('enable')
      else
        config_category_inputs.hide('fadeOut')
        config_category.multiselect('disable')
        instance_category.multiselect('disable')
