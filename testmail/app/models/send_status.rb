class SendStatus < ActiveRecord::Base
  WAITING = 1
  SENT = 2
  ERROR = 3
  ADDRESS_ERROR = 4
end
