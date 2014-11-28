//= require active_admin/base
//= require chosen.jquery.min
//= require select2.min

function addChosenClickEvent(span, clickHandler) {
  span.css({'text-decoration': 'underline'});
  span.css({'cursor': 'pointer'})
  span.on('click', clickHandler);
}

$(document).ready(function() {
  $('.chosen-select').chosen().change(function (evt, params) {
    if (params.selected) {
      var chosen = $(evt.target);
      var clickHandler = eval(chosen.attr('data-click-handler'));
      // console.log(clickHandler);
      if (clickHandler) {
        span = chosen.next('.chosen-container').find('.search-choice').last().find('span');
        addChosenClickEvent(span, clickHandler);
      }
    }
  });
  $('.chosen-select[data-click-handler]').each(function (i, select) {
    // console.log(select);
    var clickHandler = eval($(select).attr('data-click-handler'));
    // console.log($(select).parent());
    $(select).next('.chosen-container').find('.search-choice span').each(function (i, span) {
      addChosenClickEvent($(span), clickHandler);
    });
  });

  $('.tags').select2({
    tags: [],
    tokenSeparators: [","]
  });

  if ($('select#delegation_field_class_name').val() != 'Select') {
    $('#delegation_field_options_input').hide();
  }

  $('select#delegation_field_class_name').change(function() {
    if ($(this).val() == 'Select') {
      $('#delegation_field_options_input').show();
    } else {
      $('#delegation_field_options_input').hide();
    }
  });

  var delegation_field_name = $('input#delegation_field_name');
  var delegation_field_slug = $('input#delegation_field_slug');

  delegation_field_name.on('input',function() {
    delegation_field_slug.val(slugify(delegation_field_name.val()));
  });
});

function slugify(str) {
  return str.toLowerCase().replace(/[^\s\w_]/g, '').trim().replace(/[\s]+/g, '_');
}

function onCommitteeClick(e) {
  var span = $(e.target);
  var select = span.parents('.chosen-container').prev('.chosen-select');
  var optionIndex = span.next().attr('data-option-array-index');
  var option = select.children('option').eq(optionIndex);
  var id = option.attr('value');

  window.location = '/admin/committees/'+id+'/edit';
}

function onCountryClick(e) {
  var span = $(e.target);
  var select = span.parents('.chosen-container').prev('.chosen-select');
  var optionIndex = span.next().attr('data-option-array-index');
  var option = select.children('option').eq(optionIndex);
  var id = option.attr('value');

  window.location = '/admin/countries/'+id+'/edit';
}

function onCharacterClick(e) {
  var span = $(e.target);
  var select = span.parents('.chosen-container').prev('.chosen-select');
  var optionIndex = span.next().attr('data-option-array-index');
  var option = select.children('option').eq(optionIndex);
  var id = option.attr('value');

  window.location = '/admin/characters/'+id+'/edit';
}
