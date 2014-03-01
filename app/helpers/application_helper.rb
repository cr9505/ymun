module ApplicationHelper
  def icon(type)
    content_tag :i, '', class: "fa fa-#{type}"
  end
end
