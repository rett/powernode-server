$(document).bind 'edit_registrations.load', (e, obj) =>
  $commit = $('input[name=commit]')
  $commit.attr 'disabled', 'disabled'
  $terms_accepted = $('#accept_terms')
  $terms_accepted.click ->
    if $terms_accepted.is(':checked')
      $commit.removeAttr('disabled')
    else
      $commit.attr 'disabled', 'disabled'
  $form = $('form')
  stripeResponseHandler = (status, response) ->
    if response.error
      $form.find('.messages').text response.error.message
      $form.find('input[type=submit]').prop 'disabled', false
    else
      $('<input>').attr({type: 'hidden', name: 'user[stripe_card]', value: response["card"]["id"]}).appendTo($form)
      $('<input>').attr({type: 'hidden', name: 'user[stripe_card_last4]', value: response["card"]["last4"]}).appendTo($form)
      $('<input>').attr({type: 'hidden', name: 'user[stripe_token]', value: response["id"]}).appendTo($form)
      $("#user_stripe_card_number").val('')
      $("#user_stripe_card_cvc").val('')
      $form.get(0).submit()
  $form.submit ->
    $commit.attr "disabled", "disabled"
    Stripe.card.createToken this, stripeResponseHandler
    false
