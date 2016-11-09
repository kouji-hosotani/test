# encoding: utf-8

class TestMailSender

  attr_accessor :options

  # constructor.
  def initialize

    if SmtpStatus.where(:company_id => 1).exists?
      @smtp_params = SmtpStatus.where(:company_id => 1)[0]
      @options  ||= {
                  :address              => @smtp_params[:address],
                  :port                 => @smtp_params[:port],
                  :user_name            => @smtp_params[:user_name],
                  :password             => SmtpStatus.decrypt(@smtp_params[:encrypted_password]),
                  :authentication       => :plain,
                  :enable_starttls_auto => true
      }
    else
      smtp_info ||= Rails.application.secrets.smtp_info.symbolize_keys
      @options  ||= {
                  :address              => smtp_info[:address],
                  :port                 => smtp_info[:port],
                  :domain               => smtp_info[:domain],
                  :user_name            => ENV["smtp_user_name"],
                  :password             => ENV["smtp_password"],
                  :authentication       => :plain,
                  :enable_starttls_auto => true
      }
    end
    @mail = Mail.new
    @mail.delivery_method(:smtp, @options)

  end

  def send_with_beacon(subject: nil, message: nil, from: nil, to: nil, staff_id_hash: nil, serial_number: nil, attach_flag: nil, file_name: nil, link_flag: nil, attached_type_id: nil)

    # validation
    return false if from.nil? or to.nil? or staff_id_hash.nil? or serial_number.nil?

    if confirm_validity_email_address(to)

      # make html message with web beacon
      base_url      = SendMember::STATUS_CHANGE_URL
      base_url      = base_url.gsub(/%STAFF_ID%/, staff_id_hash).gsub(/%SERIAL_NUM%/, serial_number)
      img_src       = base_url.gsub(/%TYPE%/, SendMember::TYPE_OPEN)
      url           = base_url.gsub(/%TYPE%/, SendMember::TYPE_CLICK)
      web_beacon    = "<img src='#{img_src}' width='1' height='1'/>"
      if link_flag
        message = message.gsub(/%URL%/, url)
      end
      html_message  = "<html>#{message}#{web_beacon}</html>"

      if from.blank?
        from = Settings.test_mail.from
      end

      @mail.to      = to
      @mail.from    = from
      @mail.subject = subject

      html_part = Mail::Part.new do
        content_type 'text/html; charset=UTF-8'
        body html_message.gsub(/(\r\n|\r|\n)/, "<br>")
      end

      @mail.html_part = html_part

      if attach_flag and file_name.present?
        ext = ""
        # 拡張子チェック
        if attached_type_id == AttachedTypes::DOCX
          ext = ".docx"
        elsif attached_type_id == AttachedTypes::XLSX
          ext = ".xlsx"
        else
          ext = ".zip"
        end
        if File.extname(file_name) != ext
          # 拡張子を変換
          file_name = File.basename(file_name, '.*') + ext
        end

        # ワードかエクセルファイルを作成
        if attached_type_id == AttachedTypes::DOCX or attached_type_id == AttachedTypes::DOCX_ZIP
          attach_file_name = get_attach_file_name_docx staff_id_hash, serial_number, base_url
        elsif attached_type_id == AttachedTypes::XLSX or attached_type_id == AttachedTypes::XLSX_ZIP
          attach_file_name = get_attach_file_name_xlsx staff_id_hash, serial_number, base_url
        end

        # zip圧縮する
        if attached_type_id == AttachedTypes::DOCX_ZIP or attached_type_id == AttachedTypes::XLSX_ZIP
          tmp_ext = File.extname(attach_file_name)
          tmp_name = File.basename(file_name, '.*') + tmp_ext
          tmp_dir = File.dirname(attach_file_name)
          tmp_full_name = File.join(tmp_dir, tmp_name)
          if File.exist?(tmp_full_name)
            FileUtils.rm(tmp_full_name)
          end
          tmp_zip_name = File.basename(attach_file_name, '.*') + ".zip"
          tmp_zip_name = File.join(tmp_dir, tmp_zip_name)
          FileUtils.mv(attach_file_name, tmp_full_name)
          # zf = ZipFileGenerator.new(tmp_full_name, tmp_zip_name)
          # zf.write()
          # ZipFileGeneratorを使って圧縮すると、なぜか中身のファイルが壊れて修復が必要になる
          system("cd #{tmp_dir} && zip -r #{tmp_zip_name} #{tmp_name}")
          attach_file_name = tmp_zip_name
        end

        @mail.attachments[file_name] = File.read(attach_file_name)
      end

      @mail.deliver
      @mail.html_part = nil

      true
    else
      false
    end
  end

  # make attach file and return file path name
  def get_attach_file_name staff_id_hash, serial_number, base_url

    f   = File.open("#{Rails.root}/lib/tasks/doc_template/template.doc")
    doc = ''

    f.each do |line|
      doc += line
    end
    f.close

    # insert staff_id serial number into doc file
    new_doc   = doc.gsub(/%URL%/, base_url.gsub(/%TYPE%/, SendMember::TYPE_FILE_OPEN))
    file_name = "#{Rails.root}/lib/tasks/doc_template/send/#{Staff.decrypt(staff_id_hash)}_#{serial_number}.doc"
    f         = File.open(file_name, 'w')
    f.write new_doc
    f.close

    file_name
  end

  # make attach file docx and return file path name
  def get_attach_file_name_docx staff_id_hash, serial_number, base_url

    f   = File.open("#{Rails.root}/lib/tasks/doc_template/document.xml.rels")
    doc = ''

    f.each do |line|
      doc += line
    end
    f.close

    # insert staff_id serial number into doc file
    new_doc   = doc.gsub(/%URL%/, base_url.gsub(/%TYPE%/, SendMember::TYPE_FILE_OPEN)).gsub(/%HOST%/, "http://#{Settings.host}")
    file_name = "#{Rails.root}/lib/tasks/doc_template/create/word/_rels/document.xml.rels"
    f         = File.open(file_name, 'w')
    f.write new_doc
    f.close
    docx_name = "#{Rails.root}/lib/tasks/doc_template/send/#{Staff.decrypt(staff_id_hash)}_#{serial_number}.docx"
    directoryToZip = "#{Rails.root}/lib/tasks/doc_template/create/"

    zf = ZipFileGenerator.new(directoryToZip, docx_name)
    zf.write()
    docx_name
  end

  # make attach file xlsx and return file path name
  def get_attach_file_name_xlsx staff_id_hash, serial_number, base_url

    f = File.open("#{Rails.root}/lib/tasks/xlsx_template/sheet1.xml.rels")
    sheet1 = ''
    f.each do |line|
      sheet1 += line
    end
    f.close
    # insert pdf url into sheet1 file
    new_sheet1 = sheet1.gsub(/%HOST%/, "http://#{Settings.host}")
    file_name = "#{Rails.root}/lib/tasks/xlsx_template/create/xl/worksheets/_rels/sheet1.xml.rels"
    f = File.open(file_name, 'w')
    f.write new_sheet1
    f.close

    f = File.open("#{Rails.root}/lib/tasks/xlsx_template/connections.xml")
    conn = ''
    f.each do |line|
      conn += line
    end
    f.close
    # insert staff_id serial number into connections file
    new_conn = conn.gsub(/%URL%/, base_url.gsub(/%TYPE%/, SendMember::TYPE_FILE_OPEN))
    file_name = "#{Rails.root}/lib/tasks/xlsx_template/create/xl/connections.xml"
    f = File.open(file_name, 'w')
    f.write new_conn
    f.close

    xlsx_name = "#{Rails.root}/lib/tasks/xlsx_template/send/#{Staff.decrypt(staff_id_hash)}_#{serial_number}.xlsx"
    directoryToZip = "#{Rails.root}/lib/tasks/xlsx_template/create/"

    zf = ZipFileGenerator.new(directoryToZip, xlsx_name)
    zf.write()
    xlsx_name
  end

  def confirm_validity_email_address email
    domain = email.split("@").last
    records = Resolv::DNS.open do |dns|
      dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
    end

    unless records.empty?
      begin
        Net::SMTP.start(records.first.exchange.to_s, 25, 'example.com')do |smtp|
          smtp.mailfrom("example@example.com")
          smtp.rcptto(email)
        end
        return true
      rescue
        # メールアドレスが存在しない場合
        return false
      end
    else
      # 無効なドメインの場合
      return false
    end
  end

end
