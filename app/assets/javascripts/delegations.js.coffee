# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

hideAlert = ->
  $('.alert-success').delay(6000).slideUp()

successAlert = (msg) ->
  $('#alert-success').text(msg).removeClass('hidden').show()
  hideAlert()
  $("html, body").animate({ scrollTop: 0 }, "fast");

dangerAlert = (msg) ->
  $('#alert-danger').text(msg).removeClass('hidden').show()
  $("html, body").animate({ scrollTop: 0 }, "fast");

$(document).ready ->
  $('.chosen-select').chosen

  $('.add-one').click (e) ->
    e.preventDefault()
    duplicatableGroup = $('.duplicatable').last().parents('.form-group').clone()
    duplicatable = duplicatableGroup.find('.duplicatable')
    duplicatableGroup.insertBefore($(this).parent())
    name = duplicatable.attr('name').replace /\[([0-9]+)]/, (str, index) ->
      "[#{parseInt(index) + 1}]"
    duplicatable.attr('name', name)
    false

  $('input.other').each ->
    $this = $(this)
    if $this.attr('disabled')
      $this.hide()

  $('select.with-other').change (e) ->
    $this = $(this);
    input = $("input[name='#{$this.attr('name')}']")
    if ($(this).val() == 'other')
      input.attr('disabled', false).show()
    else
      input.attr('disabled', true).hide()
  .each ->
    $this = $(this);
    $this.val('other') if $this.attr('value') == 'other'

  if eurButton = $('#eur-button')
    usdButton = $('#usd-button')

    # payment page!
    if eurButton.hasClass 'active'
      # hide the EUR table
      $('#payment-usd').hide()
    else
      $('#payment-eur').hide()

    $('.payment-type-button').click ->
      paymentType = $(this).attr('data-payment-type')
      $('.payment-type-button').removeClass('active')
      $(this).addClass('active')
      $.getJSON('/delegation/change_payment_type.json', {payment_type: paymentType}, (data) ->
        if data.success
          successAlert('Payment method was successfully changed!')
        else
          dangerAlert('Something went wrong! Please try again in a little while.')
      )

    unless eurButton.hasClass('disabled')
      usdButton.click ->
        $('#payment-usd').show()
        $('#payment-eur').hide()
        usdButton.addClass('active')
        eurButton.removeClass('active')
        $('#pay-with-paypal').show()
        $.getJSON('/delegation/change_payment_currency.json', {currency: 'usd'}, (data) ->
          if data.success
            successAlert('Currency successfully changed to USD!')
          else
            dangerAlert('Something went wrong! Please try again in a little while.')
        )


      eurButton.click ->
        $('#payment-eur').show()
        $('#payment-usd').hide()
        eurButton.addClass('active')
        usdButton.removeClass('active')
        $('#pay-with-paypal').hide()
        $.getJSON('/delegation/change_payment_currency.json', {currency: 'eur'}, (data) ->
          if data.success
            successAlert('Currency successfully changed to EUR!')
          else
            dangerAlert('Something went wrong! Please try again in a little while.')
        )

  $('#payment-submit').click (e) ->
    e.preventDefault()
    $this = $(this)
    form = $this.parents('form')
    if form.find('input:checked').length
      $this.text('Please Wait...')
      form.submit()
    else
      dangerAlert('Please select a payment option or amount.')

  hideAlert()