class StoreHash
  attr_reader :pricing, :region, :conflict_hash

  def self.generate_hash
    Rails.cache.fetch("softlayer/package-46-conflict-hash", expires_in: 12.hours) do
      sh = self.new
      sh.conflict_hash.camelize_keys.to_json
    end
  end

  def initialize
    @pricing = StoreHash::Pricing.new
    @region = StoreHash::Region.new
    @conflict_hash = { price_to_price: {}, location_to_price: {}, price_to_location: {} }
    generate_conflict_hash
  end

  private
    def generate_conflict_hash
      @items
      hash = {}
      region.datacenters_ids.each { |x| conflict_hash[:location_to_price][x] = [] }
      items.each do |item|
        process_item_conflicts(item) if item.conflict_count != "0"
        process_location_conflicts(item) if item.location_conflict_count != "0"
        process_price_location_conflicts(item)
        process_capacity_conflicts(item)
      end
      hash
    end

    def process_item_conflicts(item)
      prices_for_item = pricing.prices_for(item.id)
      item.conflicts.each do |conflict|
        price_conflicts = pricing.prices_for(conflict.resource_table_id)
        if price_conflicts
          prices_for_item.each do |item_price|
            conflict_hash[:price_to_price][item_price] = [] if conflict_hash[:price_to_price][item_price].nil?
            conflict_hash[:price_to_price][item_price].concat price_conflicts
          end
        end
      end
    end

    def process_location_conflicts(item)
      prices_for_item = pricing.prices_for(item.id)
      item.location_conflicts.each do |conflict|

        # add a conflict location removing price
        datacenter = @region.datacenter_with_id(conflict.resource_table_id)
        conflict_hash[:location_to_price][datacenter.id].concat prices_for_item

        # add a conflict price removing location
        prices_for_item.each do |price|
          conflict_hash[:price_to_location][price] = [] if conflict_hash[:price_to_location][price].nil?
          conflict_hash[:price_to_location][price] << datacenter.id
        end
      end
    end

    def process_price_location_conflicts(item)
      dcs_ids = region.datacenters_ids

      # handle non base prices
      non_base_prices = item.prices.select { |x| x.location_group_id != nil }
      default_price = item.prices.select { |x| x.location_group_id.nil? }.first

      non_base_prices.each do |price|
        dcs_conflicts = region.datacenters_conflicts_for price.location_group_id
        dcs_conflicts.each { |x| conflict_hash[:location_to_price][x] << price.id }
        dcs_conflicts.each do |x|
          # do not add for non dependant datacenters
          conflict_hash[:location_to_price][x] << default_price.id if region.standard?(x)
        end
      end
    end

    def process_capacity_conflicts(item)
      item.prices.each do |price|
        unless price.capacity_restriction_type.nil?
          capacity_restriction_type = price.capacity_restriction_type
          capacity_restriction_type = "(CORE|PRIVATE_CORE)" if price.capacity_restriction_type == "CORE"
          # get restricted based on unit
          restricted = items.select { |x| x.units.match capacity_restriction_type unless x.units.nil? }
          # filter based on provided
          items_to_remove = restricted.select do |x|
            x.capacity.to_i > price.capacity_restriction_maximum.to_i or
            x.capacity.to_i < price.capacity_restriction_minimum.to_i
          end

          prices_to_remove = []
          items_to_remove.each do |item|
            prices_to_remove.concat item.prices.map { |x| x.id }
          end

          prices_to_remove.each do |priceconf|
            conflict_hash[:price_to_price][priceconf] = [] if conflict_hash[:price_to_price][priceconf].nil?
            conflict_hash[:price_to_price][priceconf] << price.id
          end
        end
      end
    end

    def items
      Rails.cache.fetch("softlayer/package-46-items", expires_in: 12.hours) do
        package = Softlayer::Product::Package.find(46)
        items_mask = 'mask[conflictCount,conflicts,globalCategoryConflictCount,globalCategoryConflicts,locationConflictCount,locationConflicts,prices[pricingLocationGroup]]'
        package.mask(items_mask).get_items
      end
    end
end
