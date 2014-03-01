module ActiveAdminHelper
 
  def admin_arbre_context
    @admin_arbre_context ||= Arbre::Context.new(assigns, self)
  end
 
  def default_renderer
    case controller.send(:resource_class).name
    when "ActiveAdmin::Page"
      "page"
    else
      "#{params[:action]}_page"
    end
  end
 
  def admin_renderer method_name, renderer_name=nil
    renderer_name             ||= default_renderer
    @renderers                ||= {}
    @renderers[renderer_name] ||= view_factory[renderer_name.to_s].new(admin_arbre_context)
    @renderers[renderer_name].send(method_name)
  end
 
  def admin_arbre_tag renderer_name, *args
    admin_arbre_context.insert_tag *([view_factory[renderer_name.to_s]] | args)
  end
 
  def admin_classes
    classes = []
    classes << params[:action]
    classes << params[:controller].gsub('/', '_')
    classes << "active_admin"
    classes << "logged_in"
    classes << active_admin_namespace.name.to_s + "_namespace"
    classes.join(" ")
  end
 
end