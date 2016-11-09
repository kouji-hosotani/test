class ApiBaseController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  # error handler
  include ErrorHandlers if Rails.env.production?

end