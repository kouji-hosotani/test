class Graph < ActiveRecord::Base

  before_destroy :delete_batch_log

  has_many :batch_log
  belongs_to :batch_period
  belongs_to :protocol
  belongs_to :encode
  belongs_to :return_code
  belongs_to :batch_url

  def delete_batch_log
    batch_log.destroy if batch_log.present?
  end

end
