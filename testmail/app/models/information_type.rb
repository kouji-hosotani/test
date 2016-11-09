class InformationType < ActiveRecord::Base
  has_many :informations
  validates :name, presence: true
  default_scope -> {where :del_flag => 0}
end
