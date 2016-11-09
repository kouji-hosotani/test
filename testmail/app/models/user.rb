class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  acts_as_paranoid
  validates :email, :uniqueness_without_deleted => true

  before_destroy :delete_profile

  has_one :profile

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  default_scope -> {where("(expired_at IS NOT NULL AND expired_at > '#{Time.now}') OR expired_at IS NULL")}

  def delete_profile
    profile.destroy if profile.present?
  end

  # override
  def email_required?
    false
  end

  def email_changed?
    false
  end
  
  def self.current_user
    Thread.current[:current_user]
  end

  def self.current_user=(usr)
    Thread.current[:current_user] = usr
  end
  
end
