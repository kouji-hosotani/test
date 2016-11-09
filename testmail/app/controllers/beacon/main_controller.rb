class Beacon::MainController < ApplicationController

  # 認証なし
  skip_before_filter :authenticate_user!

  def index

    # Get info
    @staff_id_hash = params[:staff_id_hash]
    @serial_number = params[:serial_number]
    @type          = params[:type]
    @error         = false

    if @staff_id_hash.present? & @serial_number.present?

      satff_id            = Staff.decrypt(@staff_id_hash)
      mail_reservation_id = MailReservation.find_by(serial_number: @serial_number).id
      target_params       = {
                              send_status_id:       SendStatus::SENT,
                              staff_id:             satff_id,
                              mail_reservation_id:  mail_reservation_id
      }

      target_send_memeber = SendMember.where(target_params)

      if target_send_memeber.size.zero?
        ## error if no target data
        Rails.logger.error "Mail was opened. But no target data. staff_id = #{satff_id}, mail_reservation_id = #{mail_reservation_id}"
        @error = true
      end

      target_send_memeber.each do |history|
        history.update( open_flag:      SendMember::STATUS_DETECTED, opened_at:      Time.now) if @type == SendMember::TYPE_OPEN and history.open_flag == SendMember::STATUS_NOTYET
        history.update( click_flag:     SendMember::STATUS_DETECTED, clicked_at:     Time.now) if @type == SendMember::TYPE_CLICK and history.click_flag == SendMember::STATUS_NOTYET
        history.update( file_open_flag: SendMember::STATUS_DETECTED, file_opened_at: Time.now) if @type == SendMember::TYPE_FILE_OPEN and history.file_open_flag == SendMember::STATUS_NOTYET
        begin
          history.save!
        rescue => e
          Rails.logger.error "Mail was opened. But fail updating target data. staff_id = #{satff_id}, mail_reservation_id = #{mail_reservation_id}. Throw exception #{e.message}"
          @error = true
        end
      end

    else
      #error log insert here
      Rails.logger.error "Invalid URL. url = #{request.url}"
      @error = true
    end

    if @type == SendMember::TYPE_CLICK
      # responese 200
      redirect_to "/guide/education_contents.pdf"
    else
      render :json => {:status => 200}, :status => 200
    end
  end

end
