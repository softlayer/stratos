class LoginController < ApplicationController
  skip_before_action :check_softlayer_login

  def new
    @form = LoginForm.new(OpenStruct.new)
  end

  def create
    @form = LoginForm.new(OpenStruct.new)
    if @form.validate(params[:login])
      api_user = params[:login][:api_user]
      api_key = params[:login][:api_key]

      connection = SoftlayerConnection.new(api_user, api_key)
      if connection.valid?
        cookies.signed[:api_user] = api_user
        cookies.signed[:api_key] = api_key
        WarmCacheJob.logger = nil
        WarmCacheJob.perform_later(api_user, api_key)
        redirect_to root_path, notice: "Logged In Successfully"
      else
        redirect_to login_path, alert: "Invalid Credentials"
      end
    else
      redirect_to login_path, alert: "Invalid Credentials"
    end
  end

  def destroy
    cookies.signed[:api_user] = nil
    cookies.signed[:api_key] = nil
    redirect_to login_path, notice: 'Logged Out Successfully'
  end
end