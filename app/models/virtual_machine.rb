class VirtualMachine
  include ActiveModel::Model
  attr_accessor :hostname, :domain, :datacenter

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

  def self.all
    Softlayer::Account.get_virtual_guests
  end

  def categories
    product_categories.map { |x| x.category_code }
  end

  def groups_for(category)
    product_categories.select { |x| x.category_code == category }.first.groups.map { |x| x.title }
  end

  def options_for(category, group)
    category = product_categories.select { |x| x.category_code == category }.first
    group = category.groups.select { |x| x.title == group }.first
    group.prices.map { |x| [x.item.description, x.item.id] }.uniq
  end

  def options_for_datacenter
    datacenters.map { |x| [x.long_name, x.name] }
  end

  def form_options_for(category)
    array = []
    return options_for(category, nil) if groups_for(category)[0] == nil
    product_categories.select { |x| x.category_code == category }.each do |category|
      category.groups.each do |group|
        options = group.prices.map { |x| [x.item.description, x.item.id] }.uniq
        array << [group.title, options]
      end
    end
    array
  end

  def components_price
    prices = {}
    ids = location_ids_for(datacenter)
    components.each do |component|
      prices = product_categories
      price_for_dc = guest_disk0_san.select { |x| x.item.description == option && ids.include?(x.location_group_id) }
      if price_for_dc.empty?
        price = guest_disk0_san.select { |x| x.item.description == option && ids.location_group_id.nil? }
      else
        price = default_price
      end
    end
  end

  # disk 1 is reserved for swap
  # disks = options_for_block_devices(1, true)
  # disks.first { |x| x.item_price.item.description == "10 GB (SAN)" }.template
  def options_for_block_devices(disk = 0, local = false)
    disks = create_options.block_devices.select { |x| x.template.block_devices.first.device == disk.to_s && x.template.local_disk_flag == local }
    disks.map { |x| [x.item_price.item.description, x.item_price.item.description] }
  end

  private
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
