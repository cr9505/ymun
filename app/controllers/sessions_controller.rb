class SessionsController < Devise::SessionsController
  def create
    # creds to http://stackoverflow.com/questions/5690406/rails-using-devise-with-single-table-inheritance
    rtn = super
    sign_in(resource.type.underscore, resource.type.constantize.send(:find, resource.id)) unless resource.type.nil?
    rtn
  end
end