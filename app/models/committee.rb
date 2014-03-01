class Committee < ActiveRecord::Base
  has_many :country_committees
  has_many :countries, through: :country_committees

  accepts_nested_attributes_for :country_committees, :allow_destroy => true
  
  has_many :characters

  def self.sync_with_drive
    
  end
end
