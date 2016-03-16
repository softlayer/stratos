class SoftlayerConnection
  def initialize(user, key)
    @api_user = user
    @api_key = key
    connection
  end

  def valid?
    Softlayer::Account.get_current_user
    true
  rescue Softlayer::Errors::SoapError => e
    false
  end

  def connection
    Softlayer.configure do |config|
      config.username = @api_user
      config.api_key = @api_key
      config.open_timeout = 30 # if you want specify timeout (default 5)
      config.read_timeout = 30 # if you want specify timeout (default 5)
    end
  end
end