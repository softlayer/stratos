class StoreHash::Pricing
  def initialize
    generate_prices_hash
    generate_prices_items_hash
  end

  def prices_for(item_id)
    @prices_hash[item_id]
  end

  def item_for(price_id)
    @prices_item_hash[price_id]
  end

  def items
    Rails.cache.fetch("softlayer/package-46-items", expires_in: 12.hours) do
      package = Softlayer::Product::Package.find(46)
      items_mask = 'mask[conflictCount,conflicts,globalCategoryConflictCount,globalCategoryConflicts,locationConflictCount,locationConflicts,prices[pricingLocationGroup]]'
      package.mask(items_mask).get_items
    end
  end

  private
    def generate_prices_hash
      @prices_hash = {}
      items.each do |item|
        @prices_hash[item.id] = []
        item.prices.each { |price| @prices_hash[item.id] << price.id }
      end
    end

    def generate_prices_items_hash
      @prices_item_hash = {}
      @prices_hash.each_pair do |k, v|
        v.each do |price_id|
          if @prices_item_hash.has_key? price_id
            @prices_item_hash[price_id] << k
          else
            @prices_item_hash[price_id] = [k]
          end
        end
      end
    end
end