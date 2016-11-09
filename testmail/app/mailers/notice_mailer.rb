class NoticeMailer < ActionMailer::Base
  #default from: "tuna@mediba.jp"
  default from: Settings.aws_ses.from
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.sendmail_confirm.subject
  #
  def sendmail_confirm to, url
    @url = url
    mail to: to, subject: t("notice_mailer.sendmail_confirm.subject")
  end

  def sendmail_password_reset to, url
    @url = url
    mail to: to, subject: t("notice_mailer.sendmail_password_reset.subject")
  end

  def sendmail_information subject, body
    @body = body.gsub(/\r\n|\r|\n/, "<br />").html_safe 
    to = User.all.map {|item| item.email}.join(",")
    mail to: to, subject: subject
  end
end
