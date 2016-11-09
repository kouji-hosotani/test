class MailReservation < ActiveRecord::Base

  STATUS_WATING     = 1
  STATUS_PROCESSING = 2
  STATUS_SENT       = 3

  has_one :send_mail
  belongs_to :company
  belongs_to :mail_template
  belongs_to :send_time_zone

  default_scope -> {where :del_flag => 0}
  scope :company_filter, -> {where :company_id => User.current_user.profile.company_id}

end
