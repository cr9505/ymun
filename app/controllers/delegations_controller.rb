class DelegationsController < InheritedResources::Base
  before_action :auth
  before_action :attach_id, only: [:show, :update, :edit, :edit_preferences]

  def show

  end

  def new
    unless current_user.delegation
      delegation = Delegation.new
      create_resource(delegation)
      current_user.update_attributes(delegation_id: delegation.id)
    end
    redirect_to action: :edit
  end

  def create
    @delegation = Delegation.new(params[:delegation])
    @delegation.changer = current_user
    create! do |success, failure|
      success.html do
        current_user.delegation = @delegation
        current_user.save
        redirect_to action: :show
      end
    end
  end

  def edit
    if params[:step].blank?
      if current_user.delegation.registration_finished?
        redirect_to edit_page_delegation_path(1) and return
      else
        redirect_to edit_page_delegation_path(current_user.delegation.step) and return
      end
    end
    @step = params[:step].to_i
    @page = DelegationPage.where(step: @step).first
    @fields = resource.all_fields(@page)
    @delegation = resource
    unless @page
      flash[:error] = 'Invalid Edit Page.'
      redirect_to edit_page_delegation_path(1) and return
    end
    edit!
  end

  def resource
    current_user.delegation or super
  end

  def update
    @delegation = current_user.delegation
    @delegation.changer = current_user
    @delegation.send_notification = true
    unless params[:step]
      # this is weird
      params[:step] = @delegation.step
    end
    @step = params[:step].to_i
    @delegation.saving_step = @step
    @page = DelegationPage.find_by(step: @step)
    @fields = @delegation.fields.target

    if params[:delegation].andand[:preferences_attributes]
      params[:delegation][:preferences_attributes].each do |i, pref|
        if pref[:country_id].blank?
          pref[:_destroy] = true
        end
      end
    end

    update! do |success, failure|
      flash.keep
      failure.html do
        # flash[:error] = resource.errors.inspect
        # redirect_to edit_page_delegation_path(params[:step])
        render :edit
      end
      success.html do
        curr_step = params[:step].to_i
        unless @delegation.registration_finished? || @delegation.step > curr_step
          @delegation.advance_step!
        end
        if curr_step + 1 > DelegationPage.maximum(:step)
          redirect_to delegation_payments_path
        else 
          redirect_to edit_page_delegation_path(curr_step + 1)
        end
      end
    end
  end

  def edit_preferences
    resource.pad_preferences
    edit!
  end

  def change_payment_type
    delegation = current_user.delegation
    delegation.send_notification = true
    @payment_type = params[:payment_type]
    delegation.payment_type = @payment_type
    if delegation.save
      respond_to do |format|
        format.json do
          render json: {success: true, payment_type: @payment_type}
        end
        format.html do
          flash[:notice] = 'Payment method changed successfully.'
          redirect_to delegation_payments_path
        end
      end
    else
      respond_to do |format|
        format.json do
          render json: {success: false, error: delegation.errors.inspect}
        end
        format.html do
          flash[:error] = 'Payment method could not be changed.'
          redirect_to delegation_payments_path
        end
      end
    end
  end

  def change_payment_currency
    delegation = current_user.delegation
    delegation.send_notification = true
    @currency = params[:currency]
    delegation.payment_currency = @currency
    if delegation.save
      respond_to do |format|
        format.json do
          render json: {success: true, currency: @currency}
        end
        format.html do
          flash[:notice] = 'Currency changed successfully.'
          redirect_to delegation_payments_path
        end
      end
    end
  end

  def payment
    @payment_items = current_user.delegation.payment_items

  end

  private

  def attach_id
    if current_user.delegation
      params[:id] = current_user.delegation_id
      @delegation = current_user.delegation
    else
      redirect_to action: :new
    end
  end

  def auth
    authenticate_user!
    unless current_user.type == 'Advisor'
      redirect_to after_sign_in_path_for(current_user)
    end
  end

  def permitted_params
    params.permit(:delegation => [:name, :delegation_size,
                                  address_attributes: [:id, :line1, :line2, :city, :state, :zip, :country],
                                  preferences_attributes: [:country_id, :id, :rank, :_destroy],
                                  fields_attributes: [:id, :delegation_field_id, :value],
                                  advisors_attributes: [:id, :email, :first_name, :last_name, :to_be_invited, :inviter_id, :_destroy],
                                  committee_type_selections_attributes: [:id, :delegate_count, :committee_type_id]])
  end
end
