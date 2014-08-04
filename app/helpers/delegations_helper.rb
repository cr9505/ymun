module DelegationsHelper
  def select_options(options_str)
    options_str.split(',').map do |opt|
      if opt == 'other'
        ['Other (please specify)', 'other']
      else
        [opt, opt]
      end
    end
  end

  def select_details(delegation_field_value)
    options = select_options(delegation_field_value.delegation_field.options)
    {
      options: select_options(delegation_field_value.delegation_field.options),
      is_other: (!delegation_field_value.value.blank? && !options.collect{|opt| opt[0]}.include?(delegation_field_value.value))
    }
  end

  def currency(currency_abbr)
    {
      usd: '$',
      eur: '&euro;'
    }[currency_abbr].html_safe
  end

  def error_message(delegation)
    Arbre::Context.new do
      text_node "Please correct the following errors:"

      ul do
        delegation.errors.full_messages.each do |msg|
          li "#{msg}."
        end
      end
    end.to_s
  end
end
