class PaymentsController < ActionController::Base
  include PayPal::SDK
  before_action :auth
  before_action :ensure_delegation, only: [:show, :update, :edit, :edit_preferences]
  layout 'delegations'

  def execute_payment
    @delegation = current_user.delegation
    if params[:success]
      payer_id = params[:PayerID]
      p = @delegation.payments.last
      @payment = REST::Payment.find(p.payment_id)
      if @payment.state == 'created'
        if @payment.execute(payer_id: payer_id)
          p.state = 'approved'
          p.payer_id = @payment.payer.payer_info.payer_id
          p.save
          flash[:notice] = "You were successfully charged! Thank you for registering for #{Option.get('site_title')}!"
          redirect_to action: :index and return
        else
          puts @payment.inspect
          p.state = 'declined'
          p.save
          
        end
      elsif @payment.state = 'approved'
        p.state = 'approved'
        p.payer_id = @payment.payer.payer_info.payer_id
        p.save
        flash[:notice] = "You were successfully charged! Thank you for registering for #{Option.get('site_title')}!"
        redirect_to action: :index and return
      else
        puts "ODD: payment with payment state=#{@payment.state}"
      end
    end
    flash[:error] = "There was an error processing your request and you were not charged. Please contact #{Option.get('tech_email')} for assistance."
    redirect_to delegation_payments_url
  end

  def index
    @delegation = current_user.delegation
    @payments = @delegation.approved_payments
  end

  def create
    @delegation = current_user.delegation
    @delegation.payment_type = 'paypal'
    if @delegation.payment_currency != 'usd'
      if @delegation.approved_payments.where(currency: :eur).any?
        flash[:error] = 'You may not pay with paypal, as you have already partially paid with euros.'
        redirect_to delegation_payments_url and return
      end
      @delegation.payment_currency = 'usd'
    end
    @delegation.save

    puts @delegation.inspect

    @amount =
      case params[:payment][:type]
      when 'deposit'
        Option.get('deposit_usd')
      when 'full'
        @delegation.payment_balance
      when 'custom'
        params[:payment][:amount].to_f
      else
        nil
      end

    if @amount.nil?
      flash[:error] = 'Please specify either deposit, full balance, or custom amount.'
      redirect_to delegation_payments_url and return
    end

    if @amount <= 0
      flash[:error] = 'The amount to pay cannot be zero or negative.'
      redirect_to delegation_payments_url and return
    end

    @payment = REST::Payment.new({
      :intent => "sale",
      :redirect_urls => {
        return_url: execute_delegation_payments_url(success: true),
        cancel_url: execute_delegation_payments_url(failure: true) },
      :payer => {
        :payment_method => "paypal" },
      :transactions => [{
        :amount => {
          :total => "%.2f" % @amount,
          :currency => "USD" },
        :description => "#{Option.get('site_title')} Registration Payment ($#{@amount})" }]})

    if @payment.create
      @delegation.payments << Payment.new_from_payment(@payment)
      redirect_to @payment.links.find{|l| l.rel == 'approval_url'}.href
    else
      flash[:error] = 'There was something wrong with your request and your payment could not be created.'
      p @payment
      redirect_to action: :index
    end
  end

  private

  def ensure_delegation
    unless current_user.delegation
      redirect_to controller: :delegations, action: :new
    end
  end

  def auth
    authenticate_user!
    unless current_user.type == 'Advisor'
      redirect_to after_sign_in_path_for(current_user)
    end
  end

end