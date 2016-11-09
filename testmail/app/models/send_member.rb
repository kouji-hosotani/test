class SendMember < ActiveRecord::Base

  # STATUS_CHANGE_URL = "http://#{Settings.host}/beacon?staff_id_hash=%STAFF_ID%&serial_number=%SERIAL_NUM%&type=%TYPE%"
  STATUS_CHANGE_URL = "http://#{Settings.host}/beacon?staff_id_hash=%STAFF_ID%&amp;serial_number=%SERIAL_NUM%&amp;type=%TYPE%"
  # detection type
  TYPE_OPEN         = "1"
  TYPE_CLICK        = "2"
  TYPE_FILE_OPEN    = "3"

  STATUS_NOTYET   = 1
  STATUS_DETECTED   = 2

  belongs_to :mail_reservation
  belongs_to :staff
  belongs_to :send_status
  belongs_to :open_status

  default_scope -> {where :del_flag => 0}
end
