# encoding: utf-8
namespace :send_mail do

  require 'mail'
  require "fileutils"

  desc "sending mail"
  task :exec => :environment do

    error = false

    unless MailReservation.where(status_id: MailReservation::STATUS_PROCESSING).size.zero?
      Rails.logger.info "Don't exec this process because before process is runnig."
      exit
    end

    ## check mail_reservations
    now_time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    mail_reservations = MailReservation.where{(reserved_at <= now_time) & (status_id == MailReservation::STATUS_WATING)}

    send_count = 0
    message = "Start mail_send:exec task #{Time.now}. It will process #{mail_reservations.size} mail reservations."
    Rails.logger.info message
    puts message

    ## loop mail_reservations
    mail_reservations.each do |reservation|

      begin
        reservation.status_id = MailReservation::STATUS_PROCESSING
        reservation.save!

        # mailer
        mail = TestMailSender.new

        ## get mail content
        mail_templates = MailTemplate.find reservation.mail_template_id

        ## get send_members
        send_members = SendMember.where{(mail_reservation_id == reservation.id ) & (send_status_id == SendStatus::WAITING)}

        ## 100通まわしたら数秒待つ
        ## send mail to target member
        send_members.each_with_index do |member, i|
          begin
            send_params = {
                            subject:        reservation.send_mail.subject,
                            from:           reservation.send_mail.from_name,
                            to:             member.staff.email,
                            message:        reservation.send_mail.message,
                            link_flag:      reservation.send_mail.link_flag,
                            file_name:      reservation.send_mail.file_name,
                            attach_flag:    reservation.send_mail.attach_flag,
                            attached_type_id: reservation.send_mail.attached_type_id,
                            staff_id_hash:  member.staff.encrypt_id,
                            serial_number:  reservation.serial_number
            }

            # send mail
            if mail.send_with_beacon send_params
              begin
                # regist send history
                member.send_status_id = SendStatus::SENT
                member.save!
                send_count += 1
              rescue => e
                Rails.logger.error "Mail sent. but target data updating failed...#{e.message}"
                @error = true
              end
            else
              Rails.logger.error "Invalid send params. #{send_params}"
              member.send_status_id = SendStatus::ADDRESS_ERROR
              member.save!
            end

          rescue => e
            Rails.logger.error "#{e.message}"
            @error = true
            member.send_status_id = SendStatus::ERROR
            member.save!
          end

          # 10 seconds sleep by 100 mails
          if (i % 100) == 0 and i >= 100
            sleep 10
          end

        end
        # mail_reservation has been sent
        # if no error update reservation data
        unless @error
          reservation.send_at   = Time.now
          reservation.status_id = MailReservation::STATUS_SENT
          reservation.save!
          # delete attached files
          FileUtils.rm(Dir.glob("#{Rails.root}/lib/tasks/doc_template/send/*"))
          FileUtils.rm(Dir.glob("#{Rails.root}/lib/tasks/xlsx_template/send/*"))
        else
          reservation.status_id = MailReservation::STATUS_WATING
          reservation.save!
        end
      rescue => e
        reservation.status_id = MailReservation::STATUS_WATING
        reservation.save!
      end
    end

    message = "Finish mail_send:exec task #{Time.now}. Sent #{send_count} mails."
    Rails.logger.info message
    puts message

  end
end
