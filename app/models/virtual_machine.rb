class VirtualMachine
  include ActiveModel::Model
  attr_reader :id

  attr_accessor :hostname, :domain, :hourly, :datacenter

  # system configuration
  attr_accessor :guest_core, :ram, :os, :guest_disk0, :guest_disk1, :guest_disk2, :guest_disk3, :guest_disk4

  # network options
  attr_accessor :bandwidth, :port_speed, :sec_ip_addresses, :pri_ipv6_addresses, :static_ipv6_addresses

  # system addons
  attr_accessor :os_addon, :cdp_backup, :control_panel, :database, :firewall, :av_spyware_protection
  attr_accessor :intrusion_protection, :monitoring_package

  # storage addons
  attr_accessor :evault

  # service addons
  attr_accessor :monitoring, :response, :bc_insurance

  # default
  attr_accessor :vpn_management, :vulnerability_scanner, :pri_ip_addresses, :notification, :remote_management

  # other
  attr_accessor :new_customer_setup, :premium, :managed_resource, :storage_backend_upgrade, :evault_plugin, :web_analytics

  delegate :fully_qualified_domain_name, :power_on, :power_off, :primary_ip_address, to: :softlayer_object
  delegate :primary_backend_ip_address, :provision_date, to: :softlayer_object

  def self.all
    objects = Softlayer::Account.mask('mask[powerState,status,activeTransactionCount,activeTransactions]').get_virtual_guests
    objects.map { |softlayer_object| self.build_from_softlayer_object(softlayer_object) }
  end

  def self.find(id)
    vm = self.new
    vm.softlayer_object = Softlayer::Virtual::Guest.mask('mask[powerState,status,activeTransactionCount,activeTransactions]').find(id)
    vm
  end

  def self.warm_cache
    vm = self.new
    vm.send(:datacenters)
    vm.send(:create_options)
    vm.send(:package)
    vm.send(:configuration)
    vm.send(:product_categories)
  end

  def self.build_from_softlayer_object(softlayer_object)
    vm = self.new
    vm.instance_variable_set(:@softlayer_object, softlayer_object)
    vm.instance_variable_set(:@id, softlayer_object.id)
    vm
  end

  def categories
    product_categories.map { |x| x.category_code }
  end

  def groups_for(category)
    product_categories.select { |x| x.category_code == category }.first.groups.map { |x| x.title }
  end

  def options_for_datacenter
    datacenters.map { |x| [x.long_name, x.id, {
      'data-standard-prices-flag': x.groups.select { |x| x.location_group_type_id == 82 && x.id = 1 }.empty? ? 1 : 0,
      'data-datacenter-id': x.id
    }] }
  end

  def form_options_for(category)
    Rails.cache.fetch("softlayer/46-form-options-for-#{category}", expires_in: 12.hours) do
      array = []
      return options_for(category, nil) if groups_for(category)[0] == nil
      product_categories.select { |x| x.category_code == category }.each do |category|
        category.groups.each do |group|
          options = group.prices.map { |x| [x.item.description, x.id, {
            'data-location-dependent-flag': (x.location_group_id.nil? ? 0 : 1),
            'data-item-id': x.item.id,
            'data-recurringfee': (x.recurring_fee || nil),
            'data-nonrecurringfee': "0",
            'data-hourlyfee': (x.hourly_recurring_fee || nil),
            'data-ispriceflag': "1",
            'data-item-description': x.item.description
          }] }
          array << [group.title, options]
        end
      end
      array
    end
  end

  def default_options
    default_items = product_categories.map do |preset|
      config = preset.preset_configurations
      if config.is_a? Array
        config.first.price.id
      else
        config.price.id unless config.price.nil?
      end
    end
    default_items.compact!.concat [1640, 1644, 273]
  end

  def components_price
    pricing = StoreHash::Pricing.new
    prices = {}
    prices[:total] = {hourly_fee: BigDecimal.new('0.0'), monthly_fee: BigDecimal.new('0.0')}
    prices[:components] = {}
    # process the datacenter
    unless datacenter.blank?
      location = datacenters.select { |x| x.id == datacenter.to_i }.first
      prices[:datacenter] = {
        name: "Data Center",
        item: location.name.upcase
      }
    end

    # process each component
    components.each do |component|
      category = product_categories.select { |x| x.category_code == component.to_s }.first
      price_id = self.send(component).to_i
      item_id = pricing.item_for(price_id).try(:first)
      if item_id
        item = pricing.items.select { |x| x.id == item_id }.try(:first)
        price = item.prices.select { |x| x.id == price_id }.try(:first)
        prices[:components][component] = {
          name: category.name,
          item: item.description,
          hourly_fee: price.hourly_recurring_fee,
          monthly_fee: price.recurring_fee
        }
        prices[:total][:hourly_fee] += BigDecimal.new(price.hourly_recurring_fee.to_s)
        prices[:total][:monthly_fee] += BigDecimal.new(price.recurring_fee.to_s)
      end
    end
    puts prices.inspect
    prices
  end

  def template_hash
    template = {}
    template['location'] = datacenter
    template['packageId'] = 46
    template['quantity'] = 1
    template['useHourlyPricing'] = !!hourly
    template['virtualGuests'] = [{domain: domain, hostname: hostname}]
    template['prices'] = []
    components.each do |component|
      price_id = self.send(component).to_i
      template['prices'] << {id: price_id} if price_id != 0
    end
    template['prices'].concat [{"id"=>21}, {"id"=>57}, {"id"=>420}, {"id"=>418}, {"id"=>905}]
    template
  end

  def softlayer_object=(object)
    @softlayer_object = object
  end

  def reboot
    softlayer_object.reboot_hard
  end

  def power_state
    softlayer_object.power_state.key_name
  end

  def status
    softlayer_object.status.key_name
  end

  def destroy
    softlayer_object.delete_object
    self.freeze
  end
  
  def running?
    return true if power_state == "RUNNING"
    false
  end

  def active?
    return false unless softlayer_object.active_transaction_count == "0"
    return false if provision_date.nil?
    return true if status == "ACTIVE"
    false
  end

  private
    def softlayer_object
      @softlayer_object
    end

    def options_for(category, group)
      category = product_categories.select { |x| x.category_code == category }.first
      group = category.groups.select { |x| x.title == group }.first
      group.prices.map { |x| [x.item.description, x.id, {
        'data-location-dependent-flag': (x.location_group_id.nil? ? 0 : 1),
        'data-item-id': x.item.id,
        'data-recurringfee': x.recurring_fee,
        'data-nonrecurringfee': "0",
        'data-hourlyfee': (x.hourly_recurring_fee || 0),
        'data-ispriceflag': "1",
        'data-item-description': x.item.description
      }] }
    end

    def components
      [:guest_core, :ram, :os, :guest_disk0, :guest_disk1, :guest_disk2, :guest_disk3, :guest_disk4, :bandwidth, :port_speed, :sec_ip_addresses, :pri_ipv6_addresses, :static_ipv6_addresses, :os_addon, :cdp_backup, :control_panel, :database, :firewall, :av_spyware_protection, :intrusion_protection, :monitoring_package ,:evault, :monitoring, :response, :bc_insurance]
    end

    def datacenters
      Rails.cache.fetch("softlayer/datacenters", expires_in: 12.hours) do
        Softlayer::Location::Datacenter.mask('mask[groups]').get_datacenters
      end
    end

    def create_options
      Rails.cache.fetch("softlayer/create_options", expires_in: 12.hours) do
        Softlayer::Virtual::Guest.get_create_object_options
      end
    end

    def package
      Rails.cache.fetch("softlayer/46-product_package", expires_in: 12.hours) do
        Softlayer::Product::Package.find(46)
      end
    end

    def configuration
      Rails.cache.fetch("softlayer/46-product_configuration", expires_in: 12.hours) do
        object_mask = 'mask[itemCategory[categoryCode,name,orderOptions]]'
        package.mask(object_mask).get_configuration
      end
    end

    def product_categories
      Rails.cache.fetch("softlayer/46-product_categories", expires_in: 12.hours) do
        obj_mask = 'mask[orderOptions,packageConfigurations,presetConfigurations]'
        package.mask(obj_mask).get_categories
      end
    end

    def location_ids_for(datacenter)
      datacenters.select { |x| x.name == datacenter }.first.groups.map { |x| x.id }
    end
end
