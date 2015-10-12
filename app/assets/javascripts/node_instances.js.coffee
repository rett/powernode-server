$(document).bind 'edit_node_instances.load', (e, obj) =>
  if $("input#node_instance_private_ip_static").prop("checked") == false
    $("#private_ip_settings").hide()
  $("input#node_instance_private_ip_static")
    .change ->
      if $("input#node_instance_private_ip_static").prop("checked") == true
        $("#private_ip_settings").slideDown()
      else
        $("#private_ip_settings").slideUp()
  if $("input#node_instance_private_netboot_enabled").prop("checked") == false
    $("#private_netboot_settings").hide()
  $("input#node_instance_private_netboot_enabled")
    .change ->
      if $("input#node_instance_private_netboot_enabled").prop("checked") == true
        $("#private_netboot_settings").slideDown()
      else
        $("#private_netboot_settings").slideUp()
