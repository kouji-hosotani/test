class SendMail < ActiveRecord::Base

  belongs_to :mail_reservation

  default_scope -> {where :del_flag => 0}
end
