class Users::RegistrationsController < Devise::RegistrationsController

  def interim
    @errors = {}
    @ticket = Ticket.new
  end

  def interim_create
    ticket_param = ticket_params

    email = ticket_param[:email]
    email_confirm = params[:email][:confirm]
    @errors = {}
    @errors[:email] = t(".error.email_address_format_is_incorrect") if !(email =~ (/^[a-zA-Z0-9_\.\-]+@[A-Za-z0-9_\.\-]+\.[A-Za-z0-9_\.\-]+$/))
    @errors[:email] = t(".error.enter_email_address") if email.blank?

    @errors[:email_confirm] = t(".error.email_address_format_is_incorrect") if !(email_confirm =~ (/^[a-zA-Z0-9_\.\-]+@[A-Za-z0-9_\.\-]+\.[A-Za-z0-9_\.\-]+$/))
    @errors[:email_confirm] = t(".error.enter_email_address") if email_confirm.blank?

    raise "email input error." if @errors.present?

    # check email.
    if email != email_confirm then
      @errors = {:email => t(".error.notsame_email"), :email_confirm => t(".error.notsame_email")}
      raise "email is not same confirm email."
    end

    # Mail address domain check.
    #check_flg = false
    #Rails.application.secrets.registration_mail_domain.each do |domain|
    #  check_flg = true if email.index domain
    #end

    #if check_flg == false
    #  @errors = {:email => t(".error.invalid_email_domain", :domain => Rails.application.secrets.registration_mail_domain), :email_confirm => t(".error.invalid_email_domain", :domain => Rails.application.secrets.registration_mail_domain)}
    #  raise "email is invalid domain."
    #end

    # duplicate user check.
    if User.find_by(:email => email)
      @errors = {:email => t(".error.duplicate_email"), :email_confirm => t(".error.duplicate_email")}
      raise "email is already used."
    end

    # get ticket status.
    mode = TicketMode.find_by(:name => "register_interim")

    #get ticket key.
    key = Ticket.create_ticket_key

    # get Ticket.
    ticket_data = Ticket.create_ticket key, Time.now

    # get ticket status.
    ticket_stauts = TicketStatus.find_by(:name => "new")

    # check record.
    @ticket = Ticket.new

    ActiveRecord::Base.transaction do
      # save ticket
      params = {:user_id => 0,
                :email => email,
                :ticket_mode_id => mode.id,
                :ticket => ticket_data,
                :ticket_key => key,
                :etc => 0,
                :ticket_status_id => ticket_stauts.id,
                :request_ip => @remote_ip}

      @ticket.attributes = params
      @ticket.save!

      # Send mail.
      url = "#{Settings.domain}users/sign_up/?ticket=#{ticket_data}"
      NoticeMailer.sendmail_confirm(email, url).deliver

      # Update ticket status.
      ticket_stauts = TicketStatus.find_by(:name => "gen")
      @ticket.attributes = {:ticket_status_id => ticket_stauts.id}
      @ticket.save!
    end

  rescue Exception => e
    Rails.logger.error "#{__method__} : #{e.to_s}"
    @ticket = Ticket.new if @ticket.nil?
    if @ticket.errors.messages.key?(:email)
      @errors[:email] = t(".error.email_address_format_is_incorrect")
      @errors[:email_confirm] = t(".error.email_address_format_is_incorrect")
    end
    @data = {:email => email, :email_confirm => email_confirm}
    render action: 'interim'
  else
    redirect_to :action => :interim_result, :send => email
  end

  def interim_result
  end

  def new
    # @create_station = Station.new
    # @create_unit = Unit.new
    @errors= {}
    ticket_data = params[:ticket]
    if ticket_data.blank? then
      render :template => "users/registrations/error/ticket_expire", :status => 404, :locals => {:message => 'No tickets'}
      return
    end

    check_ticket_status ticket_data

    build_resource({})

    @data = {}
  end

  def create
    #@create_station = Station.new
    #@create_unit = Unit.new

    ticket_data = params[:ticket][:data]

    if ticket_data.blank? then
      render :template => "users/registrations/error/ticket_expire", :status => 404, :locals => {:message => 'No tickets'}
      return
    end

    check_ticket_status ticket_data

    email = params[:user][:email]
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]

    name = params[:email][:name]
    name2 = params[:email][:name2]
    name_read = params[:email][:name_read]
    name_read2 = params[:email][:name_read2]
    # unit = params[:email][:unit_id]
    # station = params[:email][:station_id]

    @errors = {}
    @errors[:password] = t(".error.password_between_8_to_16") if password.length < 8 or password.length > 16
    @errors[:password] = t(".error.enter_password") if password.blank?

    @errors[:password_confirmation] = t(".error.password_between_8_to_16") if password_confirmation.length < 8 or password_confirmation.length > 16
    @errors[:password_confirmation] = t(".error.enter_password") if password_confirmation.blank?

    @errors[:name] = t(".error.enter_name") if name.blank?
    @errors[:name2] = t(".error.enter_name") if name2.blank?
    @errors[:name_read] = t(".error.enter_name_read") if name_read.blank?
    @errors[:name_read2] = t(".error.enter_name_read") if name_read2.blank?
    # @errors[:unit] = t(".error.enter_unit") if unit.blank?
    # @errors[:station] = t(".error.enter_station") if station.blank?

    build_resource(sign_up_params)

    @data = {:name_sei => name,
             :name_mei => name2,
             :name_sei_read => name_read,
             :name_mei_read => name_read2,
#             :unit_id => unit,
#             :station_id => station
    }

    raise "input error." if @errors.present?

    if password != password_confirmation then
      @errors[:password] = t(".error.notsame_password")
      @errors[:password_confirmation] = t(".error.notsame_password")
      raise "password notsame error."
    end

    ActiveRecord::Base.transaction do

      # devise.
      if !resource.save
        clean_up_passwords resource
        if @errors.blank?
          @errors[:password] = t(".error.notsame_password")
          @errors[:password_confirmation] = t(".error.notsame_password")
        end
        raise "devise error."
      end

      @data[:user_id] = resource.id
      profile = Profile.new(@data)
      profile.save!

      # update ticket.
      @ticket.attributes = {:ticket_status_id =>  @ticket_stauts["used"]}
      @ticket.save!
    end
  rescue Exception => e
    Rails.logger.error "#{__method__} : #{e.to_s}"
    render :action => "new"
  else
    redirect_to :action => "result", :user => email
  end

  def result
    user_email = params[:user]
    @user = User.find_by(:email => user_email)
  end

  def edit
    super
  end

  def update
    super
  end

  def destory
    super
  end

  def cancel
    super
  end

  def profile_edit
    @profile = current_user.profile
    @profile = Profile.new(:user_id => current_user.id) if @profile.blank?
    # @create_station = Station.new
    # @create_unit = Unit.new
    @errors = {}
  end

  def profile_update

    # @create_station = Station.new
    # @create_unit = Unit.new

    name = profile_params[:name]
    name2 = profile_params[:name2]
    name_read = profile_params[:name_read]
    name_read2 = profile_params[:name_read2]
    unit = profile_params[:unit_id]
    station = profile_params[:station_id]

    @errors = {}
    @errors[:name] = t(".error.enter_name") if name.blank?
    @errors[:name2] = t(".error.enter_name") if name2.blank?
    @errors[:name_read] = t(".error.enter_name_read") if name_read.blank?
    @errors[:name_read2] = t(".error.enter_name_read") if name_read2.blank?
    # @errors[:unit] = t(".error.enter_unit") if unit.blank?
    # @errors[:station] = t(".error.enter_station") if station.blank?

    @profile = current_user.profile
    @profile = Profile.new(:user_id => current_user.id) if @profile.blank?
    @profile.attributes = {:name_sei => name,
             :name_mei => name2,
             :name_sei_read => name_read,
             :name_mei_read => name_read2,
             # :unit_id => unit,
             # :station_id => station
      }

    raise "validation error." if @errors.present?

    @profile.save!

  rescue Exception => e
    Rails.logger.error "#{__method__} : #{e.to_s}"
    render :action => "profile_edit"
  else
    redirect_to "/"
  end

  def station_create
    ja = params[:station][:name_ja]
    #en = params[:station][:name_en]
    @errors = {}

    @errors[:name_ja] = t(".error.enter_station") if ja.blank?
    #@errors[:name_en] = t(".error.enter_station") if en.blank?

    @errors[:name_ja] = t(".error.duplicate_station") if Station.where(:name_ja => ja).length > 0
    #@errors[:name_en] = t(".error.duplicate_station") if Station.where(:name_en => en).length > 0

    if @errors.present?
      raise "enter station."
    end

    #Station.create!(:name_ja => ja, :name_en => en)
    Station.create!(:name_ja => ja)

    render :json => {:code => 200, :data => Station.all}

  rescue Exception => e
    render :json => {:code => 404, :message => @errors}
    return
  end

  def unit_create
    ja = params[:unit][:name_ja]
    #en = params[:unit][:name_en]
    station_id = params[:station_id]
    @errors = {}

    raise "not found station id" if station_id.blank?

    @errors[:name_ja] = t(".error.enter_unit") if ja.blank?
    #@errors[:name_en] = t(".error.enter_unit") if en.blank?

    @errors[:name_ja] = t(".error.duplicate_unit") if Unit.where(:station_id => station_id, :name_ja => ja).length > 0
    #@errors[:name_en] = t(".error.duplicate_unit") if Unit.where(:station_id, :name_en => en).length > 0

    raise "enter unit." if @errors.present?

    #Unit.create!(:name_ja => ja, :name_en => en, :station_id => station_id)
    Unit.create!(:name_ja => ja, :station_id => station_id)

    render :json => {:code => 200, :data => Unit.where(:station_id => station_id)}

  rescue Exception => e
    p e
    render :json => {:code => 404, :message => @errors}
    return
  end

  # common methods.
  def check_ticket_status ticket_data
    # get ticket status.
    @ticket_stauts = {}
    TicketStatus.all.each do |value|
      @ticket_stauts["#{value.name}"] = value.id
    end

    ticket_mode = TicketMode.find_by(:name => "register_interim")

    ticket = Ticket.where(:ticket_mode_id => ticket_mode.id, :ticket_status_id => @ticket_stauts["gen"]).find_by(:ticket => ticket_data)

    if ticket.blank? or ticket.ticket != ticket_data then
      raise "not active ticket."
    end

    if !Ticket.is_invalid_ticket_limit ticket.ticket_key, ticket_data then
      raise "invalid expire."
    end

    if ticket.ticket_status_id != @ticket_stauts["gen"] then
      raise "already complete proccess."
    end

    if ticket.ticket_mode_id != ticket_mode.id then
      raise "not found 'modify_mail' mode."
    end

    if User.find_by(:email => ticket.email).present?
      raise "already use this email."
    end
  rescue Exception => e
    Rails.logger.error "#{__method__} : #{e.to_s}"
    render :template => "users/registrations/error/ticket_expire", :status => 404, :locals => {:message => 'No tickets'}
    return false
  else
    @ticket = ticket
    return true
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def ticket_params
    params[:ticket] = params[:ticket].permit(:user_id, :email, :ticket_mode_id, :ticket, :ticket_key, :request_ip, :etc, :ticket_status_id)
  end

  def profile_params
    params[:profile] = params[:profile].permit(:user_id, :name, :name2, :name_read, :name_read2, :unit_id, :station_id)
  end

  protected

  def sign_in_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { :methods => methods, :only => [:password] }
  end

  def auth_options
    { :scope => resource_name, :recall => "#{controller_path}#new" }
  end
end
