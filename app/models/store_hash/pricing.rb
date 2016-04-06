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

  private
    def items
      return @items if @items
      package = Softlayer::Product::Package.find(46)
      items_mask = 'mask[conflictCount,conflicts,globalCategoryConflictCount,globalCategoryConflicts,locationConflictCount,locationConflicts,prices[pricingLocationGroup]]'
      @items = package.mask(items_mask).get_items
    end

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