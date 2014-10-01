class SeatsController < InheritedResources::Base
  respond_to :json

  before_action :auth

  before_action :set_delegation
  before_action :force_delegation

  def permitted_params
    params.permit(:seat => [:delegate_id])
  end

  def set_delegation
    @delegation = current_user.delegation
  end

  def force_delegation
    if params[:seat]
      seat_id = params[:id] || params[:seat][:id]
      seat_id = seat_id.to_i
      return true if seat_id.nil?
      if @delegation.seats.where(id: seat_id).empty?
        respond_to do |format|
          format.html do
            flash[:error] = 'This seat does not belong to the current delegation.'
            redirect_to action: :index
          end
          format.json { render json: { error: "This seat does not belong to the current delegation." }, status: :unauthorized }
        end
        return false
      end
    end
  end

  def auth
    authenticate_user!
    unless current_user.type == 'Advisor'
      redirect_to after_sign_in_path_for(current_user)
    end
  end

  def collection
    @delegates ||= begin
      @delegation.seats
    end
  end
end
