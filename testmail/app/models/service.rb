class Service < ActiveRecord::Base
  has_many :campaigns
  default_scope -> {where :del_flag => 0}  
end
