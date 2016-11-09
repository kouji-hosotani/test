class Station < ActiveRecord::Base
  has_many :profiles
  has_many :units
  
  default_scope -> {where :del_flag => 0}
end
