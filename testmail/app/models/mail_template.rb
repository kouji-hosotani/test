class MailTemplate < ActiveRecord::Base
  belongs_to :company

  scope :enable, -> {where :del_flag => 0}
  scope :company_filter, -> {where :company_id => User.current_user.profile.company_id}

  def from_name
    ""
  end
end
