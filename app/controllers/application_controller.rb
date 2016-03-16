require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html
  before_action :check_softlayer_login
  before_action :set_current_user

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def connection
    SoftlayerConnection.new(cookies.signed[:api_user], cookies.signed[:api_key])
  end

  def set_current_user
    @current_user = cookies.signed[:api_user]
  end

  private
  def check_softlayer_login
    if cookies.signed[:api_user].nil? and cookies.signed[:api_key].nil?
      redirect_to login_path
    end
  end
end
