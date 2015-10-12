$(document).bind 'edit_registrations.load', (e, obj) =>
  $commit = $('input[name=commit]')
  $commit.attr 'disabled', 'disabled'
  $terms_accepted = $('#accept_terms')
  $terms_accepted.click ->
    if $terms_accepted.is(':checked')
      $commit.removeAttr('disabled')
    else
      $commit.attr 'disabled', 'disabled'
