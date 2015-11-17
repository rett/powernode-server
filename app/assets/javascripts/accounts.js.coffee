$(document).bind 'billing_accounts.load', (e, obj) =>
  $cardForm = $('#new_credit_card')
  stripeResponseHandler = (status, response) ->
    if response.error
      $cardForm.find('.messages').text response.error.message
      $cardForm.find('input[type=submit]').prop 'disabled', false
    else
      $('<input>').attr({type: 'hidden', name: 'credit_card[stripe_card]', value: response["card"]["id"]}).appendTo($cardForm)
      $('<input>').attr({type: 'hidden', name: 'credit_card[stripe_card_last4]', value: response["card"]["last4"]}).appendTo($cardForm)
      $('<input>').attr({type: 'hidden', name: 'credit_card[stripe_token]', value: response["id"]}).appendTo($cardForm)
      $("#credit_card_number").val('')
      $("#credit_card_cvc").val('')
      $cardForm.get(0).submit()
  $cardForm.submit ->
    $("input[name=commit]").attr "disabled", "disabled"
    Stripe.card.createToken this, stripeResponseHandler
    false
