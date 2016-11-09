class AttachedTypes < ActiveRecord::Base
  NONE = 1
  DOCX = 2
  XLSX = 3
  DOCX_ZIP = 4
  XLSX_ZIP = 5

  scope :enable, -> {where :del_flag => 0}
end
