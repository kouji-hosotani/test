class MailReservation::MainController < ApplicationController
  before_action :set_templates, only: [:index]

  def index
    @staff_datas = Staff.enable.company_filter.order("id ASC")
    if SmtpStatus.company_filter.exists?
      @default_sender = SmtpStatus.company_filter.first[:from_name]
    else
      @default_sender = ""
    end

    #error msg
    gon.error = Rails.application.config.error
  end

  def create
    p params
    date = params["reserve-date"]
    range = params["js-hour"]
    template_id = params["js-temp"]
    job_name = params["job_name"]
    staffs = params["reserve"]
    staff_ids = []
    from_name = params["js-template-sender"]
    subject = params["js-template-subject"]
    message = params["js-template-message"]
    file_name = params["js-template-filename"].to_s

    staffs.each do |key, value|
      if value == "1"
        staff_ids.push(key)
      end
    end

    ActiveRecord::Base.transaction do
      mrObj = MailReservation.new()
      mrObj.mail_template_id = template_id
      mrObj.job_name = job_name
      mrObj.reserved_date = Date.parse(date)
      send_time_zone_id = SendTimeZone.where(:display_name => range).first.id
      mrObj.send_time_zone_id = send_time_zone_id
      mrObj.reserved_at = Time.parse(date.to_s + " " + SendTimeZone.find(send_time_zone_id).start_time_at.strftime("%H:%M:%S"))
      mrObj.serial_number = ""
      mrObj.save!()
      mrObj.serial_number = Digest::MD5.hexdigest(mrObj.id.to_s)
      mrObj.save!()

      mail_temp = MailTemplate.where(id: template_id).first
      send_obj = SendMail.new()
      send_obj.mail_reservation_id = mrObj.id
      send_obj.from_name = from_name
      send_obj.subject = subject
      send_obj.message = message
      send_obj.link_flag = mail_temp.link_flag
      send_obj.file_name = file_name
      send_obj.attach_flag = mail_temp.attach_flag
      send_obj.attached_type_id = mail_temp.attached_type_id
      send_obj.save!()

      staff_ids.each do |id|
        smObj = SendMember.new()
        smObj.mail_reservation_id = mrObj.id
        smObj.staff_id = id
        smObj.save!()
      end
    end

    redirect_to mail_history_url, notice: "登録しました"
  end

  def get_mail_message
    data = MailTemplate.select("subject, message, attach_flag, file_name").where("id = ?", params[:id])
    render json: data
  end

  private

  def set_templates
    @template_datas = MailTemplate.enable.company_filter.order("updated_at DESC").pluck(:subject, :id)
    @js_css_root = controller_path
  end
end
