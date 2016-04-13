class StoreHash::Region
  def initialize
    generate_dcs_hash
    generate_dcs_groups_hash
  end

  def standard?(datacenter_id)
    dc = datacenters.select { |x| x.id == datacenter_id }.first
    return false if dc.groups.select { |x| x.location_group_type_id == 82 && x.id = 1 }.empty?
    true
  end

  def datacenter_with_id(datacenter_id)
    datacenters.select { |x| x.id == datacenter_id }.first
  end

  def datacenters_for(group_id)
    @dcs_groups_hash[group_id]
  end

  def datacenters_conflicts_for(group_id)
    @dcs_hash.keys - datacenters_for(group_id)
  end

  def datacenters
    Rails.cache.fetch("softlayer/datacenters", expires_in: 12.hours) do
      Softlayer::Location::Datacenter.mask('mask[groups]').get_datacenters
    end
  end

  def datacenters_ids
    @dcs_hash.keys
  end

  private
    def generate_dcs_hash
      @dcs_hash = {}
      datacenters.each do |dc|
        @dcs_hash[dc.id] = dc.groups.map { |x| x.id }
      end
    end

    def generate_dcs_groups_hash
      @dcs_groups_hash = {}
      @dcs_hash.each_pair do |k, v|
        v.each do |group_id|
          if @dcs_groups_hash.has_key? group_id
            @dcs_groups_hash[group_id] << k
          else
            @dcs_groups_hash[group_id] = [k]
          end
        end
      end
    end
end