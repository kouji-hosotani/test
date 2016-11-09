require 'csv'
require 'nkf'

class Top::MainController < ApplicationController
  protect_from_forgery except: :create_download

  #elb health_check
  def health_check
    if valid.include?(params[:path])
      render :template => File.join('static', params[:path])
    end
  end

  def index
    #raise IpAddressRejected

    # Get informations.
    # @informations = Information.limit(10).order("created_at DESC")

    # Get logs.
    # @logs = Logs.limit(10).order("created_at DESC")

    # Get User name.
    @users = User.select(:email, :id).each_with_object({}) { |user, data| data[user.id] = user.email}

    #error msg
    gon.error = Rails.application.config.error

  end

  def download
    redirect_to action: 'index' if current_user.profile.auth_type.name != "admin"
  end

  def create_download
    redirect_to action: 'index' if current_user.profile.auth_type.name != "admin"

    start_period = Time.parse((params["start_date"].present? ? params["start_date"] : "2014-01-01") + " 00:00:00")
    end_period = Time.parse((params["end_date"].present? ? params["end_date"] : Time.now.to_date.to_s) + " 00:00:00") + 9.hours + 1.days

    hash = {}

    Logs.where(:user_id.ne => "", :user_id.exists => true, :created_at.gte => start_period, :created_at.lte => end_period).each do |log|
      next if log.request_path.index("/users/get") or log.request_path.index("assets") or log.request_path.index("stylesheet") or log.request_path.index("javascript")
      next if log.method != "GET"

      # Date to key
      date = log.created_at.to_date.to_s

      path = log.request_path.split("?")[0]

      hash[date] = {} if !hash.has_key? date
      hash[date][path] = {} if !hash[date].has_key? path
      hash[date][path][log.user_id] = 0 if !hash[date][path].has_key? log.user_id
      hash[date][path][log.user_id] += 1
    end

    master = {
      "/" => "トップページ",
      "/register_route" => "登録経路",
      "/usage_distribution" => "利用回数分布",
      "/retention_rate" => "定着率",
      "/customer_journey" => "カスタマージャーニー",
      "/users/sign_in" => "サインイン",
      "/users/sign_up" => "サインアップ",
      "/users/sign_out" => "サインアウト"
    }

    header = ["Date", "Title", "Path" ,"PV", "UU"]
    generated_csv = CSV.generate(row_sep: "\r\n", :encoding => "SJIS") do |csv|
      csv << header
      hash.each do |date, value|
        value.each do |path, data|
          pv = data.inject(0) { |num, (key,val)| num += val }
          uu = data.count
          title = master.key?(path) ? master[path] : "Other"
          title = "管理ツール" if path.index("admin")
          csv << [date, title.encode("Shift_JIS"), path, pv, uu]
        end
      end
    end

    file_name = "tmp/pv_uu_#{start_period}_#{end_period}_#{ENV['RAILS_ENV']}.csv"
    send_data generated_csv.encode('Shift_JIS', :invalid => :replace, :undef => :replace), type: 'text/csv; charset=shift_jis; header=present', disposition: "attachment; filename=#{file_name}"
  end
end
