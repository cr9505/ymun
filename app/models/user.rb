class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :invitable

  belongs_to :delegation

  attr_accessor :to_be_invited, :inviter_id

  before_validation :invite

  def to_resource
    type.underscore.to_sym
  end

  def admin?
    false
  end

  def invite
    if to_be_invited && inviter_id
      inviter = User.find(inviter_id)
      self.invite!(inviter)
    end
  end
end
