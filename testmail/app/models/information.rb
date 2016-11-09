class Information < ActiveRecord::Base
  belongs_to :information_type

  validates :description, length: { maximum: 255 }
  validates :information_type, :title, :description, presence: true

  validate :email_status

  default_scope -> {where :del_flag => 0}

  def email_status
    error_msg = I18n.t(".mail_error")
    errors.add(:is_mail, error_msg) if is_mail == true and (subject.blank? or body.blank?)
  end
end
