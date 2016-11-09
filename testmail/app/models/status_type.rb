class StatusType < ActiveRecord::Base
  before_destroy :delete_batch_log

  has_many :batch_log
  belongs_to :batch_period

  def delete_batch_log
    batch_log.destroy if batch_log.present?
  end

end
