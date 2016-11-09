class MailHistory::MainController < ApplicationController
  before_action :set_js_css_path, only: [:index]

  def index
    @mail_datas = MailReservation.company_filter.order("id DESC").page(params[:page]).per(10)
    @page = params[:page]
    #error msg
    gon.error = Rails.application.config.error
  end

  def destroy
    destroy_data = MailReservation.find params[:id]
    raise ActiveRecord::RecordNotFound if destroy_data.blank?
    # destroy_data.destroy
    destroy_data.del_flag = 1
    destroy_data.save
    SendMember.where(mail_reservation_id: params[:id]).update_all(del_flag: 1)
    redirect_to root_path
  end

  def get_filter_data
    word = params[:search_word]

    data = []
    MailReservation.company_filter.order("id DESC").each do |mail_reservation|

      if mail_reservation.send_mail.present?
        subject = mail_reservation.send_mail.subject.to_s
      elsif mail_reservation.mail_template.present?
        subject = mail_reservation.mail_template.subject.to_s
      else
        subject = ""
      end

      if mail_reservation.job_name.to_s.include?(word) or
         subject.include?(word) or
         mail_reservation.reserved_at.to_s.include?(word) or
         mail_reservation.send_at.to_s.include?(word) or
         mail_reservation.created_at.to_s.include?(word)

         write_data mail_reservation, data
      end

    end
    render :json => {:status => 200, :data => data}, :status => 200
  end

  private
    def write_data mail_reservation, data
      success_member = SendMember.where(mail_reservation_id: mail_reservation.id, send_status_id: 2).count.to_s
      all_member = SendMember.where(mail_reservation_id: mail_reservation.id).count.to_s
      data << {
          :id => mail_reservation.id,
          :company => mail_reservation.company,
          :mail_template_id => mail_reservation.mail_template_id,
          :job_name => mail_reservation.job_name,
          :subject => mail_reservation.mail_template.subject,
          :reserved_at => mail_reservation.reserved_at.strftime("%Y/%m/%d %H:%M"),
          :reserved_date => mail_reservation.reserved_date.to_s,
          :send_time_zone => mail_reservation.send_time_zone.display_name,
          :send_at => mail_reservation.send_at.to_s,
          :member_num => success_member + "/" + all_member,
          :created_at => mail_reservation.created_at.to_s
        }
    end

    def set_js_css_path
      @js_css_root = controller_path
    end
end
