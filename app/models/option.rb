class Option < ActiveRecord::Base
  before_save :reset_delegation_payment_items

  def self.get(slug)
    opt = Option.where(slug: slug.to_s).first
    if opt
      case opt.class_name
      when 'Integer'
        opt.value.to_i
      when 'String'
        opt.value
      when 'Date'
        Date.new(opt.value)
      when 'Text'
        opt.value
      end
    else
      nil
    end
  end

  def self.setup
    yield self

    opts = YAML.load_file('config/options/options.yml')
    opts['options'].each do |opt|
      if current_opt = where(slug: opt['slug']).first
        current_opt.name = opt['name']
        current_opt.value = opt['default'] if current_opt.value.blank?
        current_opt.save if current_opt.changed?
      else
        # create the option with default value
        new_opt = new
        new_opt.name = opt['name']
        new_opt.slug = opt['slug']
        new_opt.value = opt['default']
        new_opt.class_name = opt['class_name']
        new_opt.save
      end
    end
  end

  def reset_delegation_payment_items
    Delegation.reset_payment_items
  end
end
