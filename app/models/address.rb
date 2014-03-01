class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  def line3
    "#{city}, #{state} #{zip}"
  end

  def to_s
    [line1, line2, line3, country].select(&:present?).join("\n")
  end

  def to_html
    to_s.gsub(/\n/, "\n<br />").html_safe
  end
end
