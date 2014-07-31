class Option < ActiveRecord::Base
  before_save :reset_delegation_payment_items

  before_save :clear_options_cache

  @@cache = {}

  def self.get(slug)
    @@cache[slug] ||= begin
      opt = Option.where(slug: slug.to_s).first
      if opt && opt.value.present?
        case opt.class_name
        when 'Integer'
          opt.value.to_i
        when 'String'
          opt.value
        when 'Date'
          Date.parse(opt.value)
        when 'Text'
          opt.value.andand.html_safe
        when 'Boolean'
          if opt.value =~ (/(true|t|yes|y|1)$/i)
            true
          else
            false
          end
        end
      else
        nil
      end
    end
  end

  def self.setup
    yield self

    if ActiveRecord::Base.connection.table_exists? 'options'
      opts = YAML.load_file('config/options/options.yml')
      opts['options'].each do |opt|
        if current_opt = where(slug: opt['slug']).first
          current_opt.name = opt['name']
          current_opt.class_name = opt['class_name']
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
  end

  def self.clear_cache
    @@cache = {}
  end

  def self.stub(slug, value)
    @@cache[slug] = value
  end

  def reset_delegation_payment_items
    Delegation.reset_payment_items
  end

  def clear_options_cache
    Option.clear_cache
  end
end
