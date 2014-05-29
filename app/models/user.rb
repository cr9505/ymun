require 'digest'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :invitable

  belongs_to :delegation

  attr_accessor :to_be_invited, :inviter_id

  before_validation :make_temp_pass
  after_save :invite

  def to_resource
    type.underscore.to_sym
  end

  def admin?
    false
  end

  def make_temp_pass
    if to_be_invited && inviter_id
      @password = Digest::SHA1.hexdigest(email + Date.new.to_s)
      skip_confirmation!
    end
  end

  def invite
    if @to_be_invited && @inviter_id
      inviter = User.find(@inviter_id)
      @to_be_invited = @inviter_id = nil
      @password = ''
      self.invite!(inviter)
    end
  end
end
