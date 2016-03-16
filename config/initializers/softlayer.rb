Softlayer.configure do |config|
  # API User and Key will be set on login
  # config.username = <API_USER>
  # config.api_key = <API_KEY>
  config.open_timeout = 30 # if you want specify timeout (default 5)
  config.read_timeout = 30 # if you want specify timeout (default 5)
end
