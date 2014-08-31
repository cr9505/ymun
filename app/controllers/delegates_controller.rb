class DelegatesController < InheritedResources::Base
  respond_to :html, :json

  before_action :auth
  before_action :set_delegation
  before_action :force_delegation, only: [:update, :destroy]

  layout 'delegations'

  def create
    if params[:delegate]
      if params[:delegate][:delegation_id].blank?
        params[:delegate][:delegation_id] = current_user.delegation_id
      end
    end
    create!
  end

  protected

  def force_delegation
    if params[:delegate]
      delegate_id = params[:id] || params[:delegate][:id]
      delegate_id = delegate_id.to_i
      return true if delegate_id.nil?
      if @delegation.delegates.where(id: delegate_id).empty?
        respond_to do |format|
          format.html do
            flash[:error] = 'This delegate does not belong to the current delegation.'
            redirect_to action: :index
          end
          format.json { render json: { error: "This delegate does not belong to the current delegation." }, status: :unauthorized }
        end
        return false
      end
    end
  end

  def set_delegation
    @delegation = current_user.delegation
  end

  def auth
    authenticate_user!
    unless ['Advisor', 'Delegate'].include? current_user.type
      redirect_to after_sign_in_path_for(current_user)
    end
  end

  def permitted_params
    params.permit(:delegate => [:first_name, :last_name, :email, :delegation_id])
  end

  def collection
    @delegates ||= begin
      dels = @delegation.delegates.to_a
      (dels.length ... @delegation.delegation_size).each do |i|
        dels << Delegate.new(delegation_id: @delegation_id)
      end
      dels
    end
  end
end