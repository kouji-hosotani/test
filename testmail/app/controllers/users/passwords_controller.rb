class Users::PasswordsController < Devise::PasswordsController
    
  def new
    @errors = {}
    @ticket = Ticket.new
    @data = {}
  end

  def create
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
    check_flg = false
    Settings.registration_mail_domain.each do |domain|
      check_flg = true if email.index domain
    end
    
    if check_flg == false
      @errors = {:email => t(".error.invalid_email_domain", :domain => Settings.registration_mail_domain), :email_confirm => t(".error.invalid_email_domain", :domain => Settings.registration_mail_domain)}
      raise "email is invalid domain."
    end

    # duplicate user check.
    if User.find_by(:email => email).blank?
      @errors = {:email => t(".error.duplicate_email"), :email_confirm => t(".error.duplicate_email")}
      raise "email is not found."
    end
     
    # get ticket status.
    mode = TicketMode.find_by(:name => "reset_password_interim")

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

       # for devise.
      user = User.find_by(:email => email)
      if user.present?
        user.attributes = {:reset_password_token => ticket_data,
                           :reset_password_sent_at => Time.now.utc}
        user.save!
      end

      # Send mail.
      url = "#{Settings.domain}users/password/edit?reset_password_token=#{ticket_data}"
      NoticeMailer.sendmail_password_reset(email, url).deliver

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
    render action: :new
  else
    redirect_to action: :result, :send => email
  end

  def result
  end

  def edit
    @errors= {}
    ticket_data = params[:reset_password_token]
    if ticket_data.blank? then
      raise "not ticket."
    end
    
    check_ticket_status ticket_data
  end

  def update
    ticket_data = params[:ticket][:data]
    if ticket_data.blank? then
      raise "not ticket."
    end

    check_ticket_status ticket_data
    
    email = params[:ticket][:email]
    password = params[:comfirm][:password]
    password_confirmation = params[:comfirm][:password_confirmation]

    @errors = {}
    @errors[:password] = t(".error.password_between_8_to_16") if password.length < 8 or password.length > 16  
    @errors[:password] = t(".error.enter_password") if password.blank?    
       
    @errors[:password_confirmation] = t(".error.password_between_8_to_16") if password_confirmation.length < 8 or password_confirmation.length > 16  
    @errors[:password_confirmation] = t(".error.enter_password") if password_confirmation.blank? 
    
    raise "input error." if @errors.present?
    
    if password != password_confirmation then
      @errors[:password] = t(".error.notsame_password")
      @errors[:password_confirmation] = t(".error.notsame_password")
      raise "password notsame error."
    end

    ActiveRecord::Base.transaction do
      reset_token = @user.reset_password_token

      if (@ticket.ticket == reset_token)
        @user.reset_password!(password, password_confirmation)
      else
        Rails.logger.error resource.errors.full_messages
        Rails.logger.error resource_params
        @errors[:password] = resource.errors.full_messages[0]
        @errors[:password_confirmation] = resource.errors.full_messages[0]
        raise "password notsame error."
      end
      @user.attributes = {:reset_password_token => reset_token}
      @user.save!

      # update ticket.
      @ticket.attributes = {:ticket_status_id =>  @ticket_stauts["used"]}
      @ticket.save!
    end
  rescue Exception => e
    Rails.logger.error "#{__method__} : #{e.to_s}"
    render :action => "edit" and return
  else
    redirect_to :action => "update_result"
  end

  def update_result
  end



  # common methods.
  def check_ticket_status ticket_data
    # get ticket status.
    @ticket_stauts = {}
    TicketStatus.all.each do |value|
      @ticket_stauts["#{value.name}"] = value.id
    end
    
    ticket_mode = TicketMode.find_by(:name => "reset_password_interim")
    
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
    
    @user =  User.find_by(:email => ticket.email)
    if @user.blank?
      raise "not found use this email."
    end
  rescue Exception => e
    Rails.logger.error "#{__method__} : #{e.to_s}"
    render :template => "users/passwords/error/ticket_expire", :status => 404, :locals => {:message => 'No tickets'} and return
    return false
  else
    @ticket = ticket
    return true
  end

  def build_resource(hash=nil)
    self.resource = resource_class.new_with_session(hash || {}, session)
  end

  private    
  # Never trust parameters from the scary internet, only allow the white list through.
  def ticket_params
    params[:ticket] = params[:ticket].permit(:user_id, :email, :ticket_mode_id, :ticket, :ticket_key, :request_ip, :etc, :ticket_status_id) 
  end
  
end
