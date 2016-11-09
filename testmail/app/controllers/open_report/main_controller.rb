class OpenReport::MainController < ApplicationController
  before_action :set_js_css_path, only: [:show]

  def show
    @reserve_data = MailReservation.where("id = ?", params[:id]).first
    @member_datas = SendMember.where("mail_reservation_id = ?", params[:id]).order("id ASC")
    if @reserve_data.send_mail.present?
      @template = @reserve_data.send_mail
    else
      @template = MailTemplate.find(@reserve_data.mail_template_id)
    end
    @@temp_tra_type = MailTemplate.find(@reserve_data.mail_template_id)
    @@table_data = nil
    @attached_types = AttachedTypes.enable.where("id > 1").pluck(:name_ja, :id)

    #error msg
    gon.error = Rails.application.config.error
  end

  def export_csv
    if @@table_data.nil?
      @@table_data = []
      SendMember.where("mail_reservation_id = ?", params[:id]).order("id ASC").each do |data|
        write_data data, @@table_data
      end
    end

    csv = CSV.generate(encoding: 'UTF-8') do |array|
      header = ['ID', 'メールアドレス', '名前', '部署・部門名', '課名', '拠点', '役職', '送信状態', 'メール開封状況', 'メール開封日', 'メール開封時間']
      unless @@temp_tra_type.link_flag.blank?
        header.push('リンククリック状況', 'リンククリック日', 'リンククリック時間')
      end
      unless @@temp_tra_type.attach_flag.blank?
        header.push('添付ファイル開封状況', '添付ファイル開封日', '添付ファイル開封時間')
      end
      array << header
      @@table_data.each do |data|
        row = [data[0], data[13], data[1], data[2], data[3], data[4], data[5], data[6]]
        date = data[8].split
        row.push(data[7], date[0], date[1])
        unless @@temp_tra_type.link_flag.blank?
          date = data[10].split
          row.push(data[9], date[0], date[1])
        end
        unless @@temp_tra_type.attach_flag.blank?
          date = data[12].split
          row.push(data[11], date[0], date[1])
        end
        array << row
      end

    end
    # UTF-8でcsvを出力
    send_data csv.encode('UTF-8'), type: 'text/csv; charset=UTF-8; header=present', :disposition => "attachment", :filename => "開封レポート.csv"
  end

  def get_filter_data
    word = params[:search_word]

    data = []
    SendMember.where("mail_reservation_id = ?", params[:id]).order("id ASC").each do |member_data|

      if (!member_data.staff.name_sei.blank? and member_data.staff.name_sei.include?(word)) or
        (!member_data.staff.name_mei.blank? and member_data.staff.name_mei.include?(word)) or
        (!member_data.staff.email.blank? and member_data.staff.email.include?(word)) or
        (!member_data.staff.unit.blank? and member_data.staff.unit.include?(word)) or
        (!member_data.staff.department.blank? and member_data.staff.department.include?(word)) or
        (!member_data.staff.region.blank? and member_data.staff.region.include?(word)) or
        (!member_data.staff.post.blank? and member_data.staff.post.include?(word)) or
        member_data.send_status.name_ja.include?(word)
        write_data member_data, data
      end

    end
    @@table_data = data
    render :json => {:status => 200, :data => data}, :status => 200
  end

  private
    def write_data member_data, data
      if member_data.staff.present?
        no = data.size + 1
        email = member_data.staff.email ? member_data.staff.email : ""
        name = get_name(member_data.staff.name_sei, member_data.staff.name_mei)
        unit = member_data.staff.unit ? member_data.staff.unit : ""
        department = member_data.staff.department ? member_data.staff.department : ""
        region = member_data.staff.region ? member_data.staff.region : ""
        post = member_data.staff.post ? member_data.staff.post : ""
        send_status = member_data.send_status.name_ja
        open_flag = OpenStatus.find(member_data.open_flag).name_ja
        opened_at = member_data.opened_at.present? ? member_data.opened_at.to_s : ""
        click_flag = @@temp_tra_type.link_flag ? OpenStatus.find(member_data.click_flag).name_ja : ""
        clicked_at = member_data.clicked_at.present? ? member_data.clicked_at.to_s : ""
        file_open_flag = @@temp_tra_type.attach_flag ? OpenStatus.find(member_data.file_open_flag).name_ja : ""
        file_opened_at = member_data.file_opened_at.present? ? member_data.file_opened_at.to_s : ""
        data << [
          no,
          name,
          unit,
          department,
          region,
          post,
          send_status,
          open_flag,
          opened_at,
          click_flag,
          clicked_at,
          file_open_flag,
          file_opened_at,
          email
        ]
      end
    end

    def get_name sei, mei
      sei = sei.present? ? sei : ""
      mei = mei.present? ? mei : ""
      name = sei + " " + mei
      name.strip
    end

    def set_js_css_path
      @js_css_root = controller_path
    end
end
