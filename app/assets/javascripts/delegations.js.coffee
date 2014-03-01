# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('.chosen-select').chosen

  $('.add-one').click (e) ->
    e.preventDefault()
    duplicatable_group = $('.duplicatable').last().parents('.form-group').clone()
    duplicatable = duplicatable_group.find('.duplicatable')
    duplicatable_group.insertBefore($(this).parent())
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
