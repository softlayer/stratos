class WarmStoreHashCacheJob < WarmCacheJob
  queue_as :default

  def perform(api_user, api_key)
    SoftlayerConnection.new(api_user, api_key)
    StoreHash.generate_hash
  end
end
