require 'kconv'
class StaffRegister::MainController < ApplicationController

  def index
    @staffs = Staff.enable.company_filter.order(:seq_no).page(params[:page]).per(1000)
    @page = params[:page]
    @@base_data = Staff.enable.company_filter
  end

  def new
    @staff = Staff.new
    @action = "create"
    @method = "post"
    @errors = {}
  end

  def create
    create_staff params, true
  end

  def edit
    @staff = Staff.find params[:id]
    @action = "update"
    @method = "put"
    @errors = {}
  end

  def update
    create_staff params, false
  end

  def destroy
    destroy_data = Staff.find params[:id]
    raise ActiveRecord::RecordNotFound if destroy_data.blank?
    destroy_data.del_flag = 1
    destroy_data.save
    redirect_to staff_register_path
  end

  def import_csv
    file = params[:csv_file]
    csv_text = file.read

    err_msg = ""
    email_array = []
    records = 0
    # CSV解析、データ登録
    Staff.transaction do

      @@base_data.update_all(:del_flag => 1)

      CSV.parse(Kconv.toutf8(csv_text)) do |row|
        if records == 0
          records += 1
          next
        end

        # Emailチェック
        email = row[0]
        if email.blank?
          err_msg += "メールアドレスが空欄です。:#{records + 1}行目</br>"
        elsif !(email =~ (/^[a-zA-Z0-9_\.\-]+@[A-Za-z0-9_\.\-]+\.[A-Za-z0-9_\.\-]+$/))
          err_msg += "メールアドレスを正しく入力して下さい:#{records + 1}行目</br>"
        elsif email_array.include?(email)
          err_msg += "メールアドレスが重複しています:#{records + 1}行目</br>"
        end
        email_array.push email
        next if err_msg.present?

        staff = Staff.company_filter.find_by(email: email)
        if staff.blank?
          staff = Staff.new
        end

        staff.company_id = current_user.profile.company_id
        staff.seq_no = records
        staff.email = row[0]
        staff.name_sei = row[1]
        staff.name_mei = row[2]
        staff.unit = row[3]
        staff.department = row[4]
        staff.region = row[5]
        staff.post = row[6]
        staff.del_flag = 0

        staff.save!
        records += 1
      end
      raise err_msg if err_msg.present?
    end

    render :json => {:status => 200}, :status => 200 and return

    rescue Exception => e
      logger.error e
      render :json => {:status => 404, :message => e.message}, :status => 500 and return
  end

  def export_csv
    csv = CSV.generate( encoding: 'UTF-8' ) do |array|
      array << ['メールアドレス', '姓', '名', '部署・部門名', '課名', '拠点', '役職' ]
      @@base_data.each do |data|
        array << [
          data[:email],
          data[:name_sei],
          data[:name_mei],
          data[:unit],
          data[:department],
          data[:region],
          data[:post]
        ]
      end

    end
    # UTF-8でcsvを出力
    send_data csv.encode('UTF-8'), type: 'text/csv; charset=UTF-8; header=present', :disposition => "attachment", :filename => "送信先一覧.csv"
  end

  def get_filter_data
    word = params[:search_word]
    data = []
    @@base_data.each do |staff|

      if staff.email.include?(word) or (staff.name_sei.present? and staff.name_sei.include?(word)) or
        (staff.name_mei.present? and staff.name_mei.include?(word)) or
        (staff.unit.present? and staff.unit.include?(word)) or
        (staff.department.present? and staff.department.include?(word)) or
        (staff.region.present? and staff.region.include?(word)) or
        (staff.post.present? and staff.post.include?(word))

        write_data staff, data
        next
      end

    end
    render :json => {:status => 200, :data => data}, :status => 200 and return

  end

  private
    def create_staff params, is_create

      if is_create
        seq_no = @@base_data.maximum(:seq_no)
        seq_no = seq_no.present? ? seq_no + 1 : 1
      else
        seq_no = params[:staff][:seq_no]
      end

      name_sei = params[:staff][:name_sei]
      name_mei = params[:staff][:name_mei]
      unit = params[:staff][:unit]
      department = params[:staff][:department]
      region = params[:staff][:region]
      post = params[:staff][:post]
      email = params[:staff][:email]

      # パラメータ作成
      @staff = is_create ? Staff.new : Staff.find(params[:id])
      before_email = @staff[:email]
      staff_attribute = {:company_id => current_user.profile.company_id, :seq_no => seq_no,
        :name_sei => name_sei, :name_mei => name_mei, :unit => unit, :department => department,
        :region => region, :post => post, :email => email}
      @staff.attributes = staff_attribute

      # パラメータチェック
      @errors = {}
      if is_create
        @errors[:email] = "メールアドレスが重複しています" if @@base_data.exists?(email: email)
      else
        @errors[:email] = "メールアドレスが重複しています" if before_email != email and @@base_data.exists?(email: email)
      end
      @errors[:email] = "メールアドレスを正しく入力して下さい" if !(email =~ (/^[a-zA-Z0-9_\.\-]+@[A-Za-z0-9_\.\-]+\.[A-Za-z0-9_\.\-]+$/))
      @errors[:email] = "メールアドレスを入力してください" if email.blank?
      raise if @errors.present?

      ActiveRecord::Base.transaction do
        @staff.save!
      end

      rescue Exception => e
        Rails.logger.error "#{__method__} : #{e.to_s}"
        @errors[:message] = e.to_s if e.present?
        @action = "create"
        @method = "post"
        render :action => :new
      else
        redirect_to staff_register_path
    end

    def write_data staff, data
      data << {
          :id => staff.id,
          :email => staff.email,
          :name_sei => staff.name_sei.present? ? staff.name_sei : "",
          :name_mei => staff.name_mei.present? ? staff.name_mei : "",
          :unit => staff.unit.present? ? staff.unit : "",
          :department => staff.department.present? ? staff.department : "",
          :region => staff.region.present? ? staff.region : "",
          :post => staff.post.present? ? staff.post : ""
        }
    end

end
