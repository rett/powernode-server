$(document).bind 'edit_provider_volumes.load', (e, obj) =>
  $("#provider_volume_provider_region_id")
    .change ->
      provider_region = $("select#provider_volume_provider_region_id :selected").val()
      update_provider_region_items_url = $("form.provider_volume").select(".provider_volume").attr("action") + "/update_provider_region_items/#{provider_region}"
      jQuery.ajax(url: update_provider_region_items_url, dataType: 'script')
  if $("input#provider_volume_custom_mount_script").prop("checked") == false
    $("#custom_mount_script_settings").hide()
  $("input#provider_volume_custom_mount_script")
    .change ->
      if $("input#provider_volume_custom_mount_script").prop("checked") == true
        $("#custom_mount_script_settings").slideDown()
      else
        $("#custom_mount_script_settings").slideUp()
  if $("input#provider_volume_raid").prop("checked") == false
    $("#raid_level").hide()
  $("input#provider_volume_raid")
    .change ->
      if $("input#provider_volume_raid").prop("checked") == false
        $("#raid_level").slideUp()
      if $("input#provider_volume_raid").prop("checked") == true
        $("#raid_level").slideDown()
