class VirtualMachine::Pricing
  class << self
    def price_for(vm)
    end

    def groups_for_datacenter(datacenter)
      datacenter = location_groups.select { |x| x.name == datacenter }.first
      datacenter.groups.map { |x| x.id }
    end

    def location_groups
      Rails.cache.fetch("softlayer/location_groups", expires_in: 12.hours) do
        Softlayer::Location::Datacenter.mask(location_object_mask).get_datacenters
      end
    end

    def price_options
    end
  end
end