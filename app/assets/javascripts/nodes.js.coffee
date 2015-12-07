$(document).bind 'edit_nodes.load', (e, obj) =>
  if $('input#node_custom_sync_script').prop('checked') == false
    $('#custom_sync_script_settings').hide()
  $('input#node_custom_sync_script')
    .change ->
      if $('input#node_custom_sync_script').prop('checked') == true
        $('#custom_sync_script_settings').slideDown()
      else
        $('#custom_sync_script_settings').slideUp()

$(document).bind 'show_nodes.load', (e, obj) =>
  $('#create_physical_instance_button').attr('disabled', 'disabled')
  $('input#node_instance_params_name')
    .on 'input', ->
      if $('#node_instance_params_name').val() is ''
        $('#create_physical_instance_button').attr('disabled', 'disabled')
      else
        $('#create_physical_instance_button').removeAttr('disabled')
  $('#provider_connection_id')
    .change ->
      if $('select#provider_connection_id :selected').val() is ''
        $('#create_cloud_instance_button').attr('disabled', 'disabled')
        $('#provider_region_select').hide()
        $('#provider_availability_zone_select').hide()
        $('#provider_instance_type_select').hide()
        $('#provider_network_subnet_select').hide()
      $('#provider_region_id').change()
  $('#provider_region_id')
    .change ->
      provider_connection = $('select#provider_connection_id :selected').val()
      provider_region = $('select#provider_region_id :selected').val()
      if provider_connection
        update_provider_items_url = $('#node').data('id') + '/update_provider_items'
        $.ajax(url: update_provider_items_url, dataType: 'script', data: {
          provider_connection_id: provider_connection,
          provider_region_id: provider_region })
          .done ->
            if $('select#provider_connection_id :selected').val() is ''
              $('#create_cloud_instance_button').attr('disabled', 'disabled')
              $('#provider_region_select').hide()
              $('#provider_availability_zone_select').hide()
              $('#provider_instance_type_select').hide()
              $('#provider_network_subnet_select').hide()
            else
              $('#provider_region_select').fadeIn()
            if $('select#provider_region_id :selected').val() is ''
              $('#create_cloud_instance_button').attr('disabled', 'disabled')
            else
              $('#create_cloud_instance_button').removeAttr('disabled')
            if $('select#provider_availability_zone_id option').size() > 1
              $('#provider_availability_zone_select').fadeIn()
            else
              $('#provider_availability_zone_select').hide()
            if $('select#provider_instance_type_id option').size() > 1
              $('#provider_instance_type_select').fadeIn()
            else
              $('#provider_instance_type_select').hide()
            if $('select#provider_network_subnet_id option').size() > 1
              $('#provider_network_subnet_select').fadeIn()
            else
              $('#provider_network_subnet_select').hide()
  $('#provider_availability_zone_id')
    .change ->
      provider_availability_zone = $('select#provider_availability_zone_id :selected').val()
      provider_connection = $('select#provider_connection_id :selected').val()
      provider_region = $('select#provider_region_id :selected').val()
      provider_instance_type = $('select#provider_instance_type_id :selected').val()
      if provider_region
        update_provider_items_url = $('#node').data('id') + '/update_provider_items'
        $.ajax(url: update_provider_items_url, dataType: 'script', data: {
          provider_connection_id: provider_connection,
          provider_region_id: provider_region,
          provider_availability_zone_id: provider_availability_zone,
          provider_instance_type_id: provider_instance_type })
          .done ->
            if $('select#provider_network_subnet_id option').size() > 1
              $('#provider_network_subnet_select').fadeIn()
            else
              $('#provider_network_subnet_select').hide()
  if $('select#provider_connection_id :selected').val() is ''
    $('#provider_connection_id').change()
