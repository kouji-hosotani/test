class Management::SmtpinfoController < ApplicationController

  def index
    if SmtpStatus.company_filter.exists?
      @smtpinfos = SmtpStatus.company_filter[0]
    else
      @smtpinfos = SmtpStatus.new
    end
  end

  def edit
    address = params[:smtp_status][:address]
    port = params[:smtp_status][:port]
    user_name = params[:smtp_status][:user_name]
    encrypted_password = SmtpStatus.encrypt(params[:smtp_status][:encrypted_password])
    from_name = params[:smtp_status][:from_name]
    
    if SmtpStatus.company_filter.exists?
      info = SmtpStatus.company_filter[0]
    else
      info = SmtpStatus.new
    end
    
    # パラメータ作成
    smtp_attribute = {:company_id => current_user.profile.company_id, :address => address, 
      :port => port, :user_name => user_name, :encrypted_password => encrypted_password, :from_name => from_name}
    info.attributes = smtp_attribute
    ActiveRecord::Base.transaction do
      info.save!
    end

    rescue Exception => e
      Rails.logger.error "#{__method__} : #{e.to_s}"
      @errors[:message] = e.to_s if e.present?
      @action = "create"
      @method = "post"
      render :action => :new
    else
      redirect_to root_path
  end
end
