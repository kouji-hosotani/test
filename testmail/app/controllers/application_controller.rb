class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  #check if user not login
  before_action :set_common_variables, :check_profile, :set_locale, :authenticate_user!, :set_current_user
  # before_action :logging
  before_action :daily_login_check

  # after_filter :cors_set_access_control_headers


  class Forbidden < ActionController::ActionControllerError; end
  class IpAddressRejected < ActionController::ActionControllerError; end

  # error handler
  include ErrorHandlers if Rails.env.production?

  #elb health_check
  def health_check
    if valid.include?(params[:path])
      render :template => File.join('static', params[:path])
    end
  end

  # For all responses in this controller, return the CORS access control headers.
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  protected

  # 例外ハンドル
  if !Rails.env.development?
    rescue_from Exception,                        with: :render_500
    rescue_from ActiveRecord::RecordNotFound,     with: :render_404
    rescue_from ActionController::RoutingError,   with: :render_404
  end

  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end

  def render_404(e = nil)
    logger.info "Rendering 404 with exception: #{e.message}" if e

    if request.xhr?
      render json: { error: '404 error' }, status: 404
    else
      format = params[:format] == :json ? :json : :html
      render template: 'errors/error_404', formats: format, status: 404, layout: 'application', content_type: 'text/html'
    end
  end

  def render_500(e = nil)
    logger.info "Rendering 500 with exception: #{e.message}" if e
    if request.xhr?
      render json: { error: '500 error' }, status: 500
    else
      format = params[:format] == :json ? :json : :html
      render template: 'errors/error_500', formats: format, status: 500, layout: 'application', content_type: 'text/html'
    end
  end
  # end of 例外ハンドル

  # Logger.
  def logging
    if current_user.present?
      logs = {
        "method" => request.request_method,
        "request_path" => request.fullpath,
        "ip" => request.ip,
        "referer" => request.referer,
        "ua" => request.user_agent,
        "controller" => controller_name,
        "action" => action_name,
        "params" => params,
        "user_id" => current_user.try(:id)
      }

      log = Logs.new(logs)
      log.save
    end
  end

  def daily_login_check
    return if current_user.blank?
    gon.is_terms = (current_user.last_visited_at.blank? or current_user.last_visited_at.to_date < Date.today.to_date) ? true : false
    # Write last visited time.
    p "Error: Can not write last_visited_at" if current_user.update(:last_visited_at => Time.now) == false
  end

  def set_current_user
    User.current_user = current_user
  end


  #set locale
  def set_locale
    @hl = (%w"ja en".include? params[:hl]) ? params[:hl] : :ja
    if %w"ja en".include? @hl
      I18n.locale = @hl.to_sym
    else
      I18n.locale = :ja
    end
  end

  #set common variables
  def set_common_variables
    @js_css_root = controller_path + "/" + action_name if !controller_name.index("devise")
    @remote_ip = request.remote_ip
  end

  def check_profile
    return if current_user.blank?
    return if current_user.profile.present?
    return if controller_name == "registrations" and action_name.index "profile"
    redirect_to "/users/profile/edit"
  end

end
