class Profile < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :user
  belongs_to :auth_type
  belongs_to :company
  # belongs_to :unit
  # belongs_to :station
  validates :name_sei, :name_sei_read, :name_mei, :name_mei_read, presence: true

end
