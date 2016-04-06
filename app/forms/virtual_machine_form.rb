class VirtualMachineForm < Reform::Form
  property :hostname
  property :domain
  property :datacenter
  property :guest_core
  property :ram
  property :os
  property :guest_disk0
  property :guest_disk1
  property :guest_disk2
  property :guest_disk3
  property :guest_disk4
  property :bandwidth
  property :port_speed
  property :port_speed
  property :sec_ip_addresses
  property :pri_ipv6_addresses
  property :static_ipv6_addresses
  property :os_addon
  property :cdp_backup
  property :control_panel
  property :database
  property :firewall
  property :av_spyware_protection
  property :intrusion_protection
  property :monitoring_package
  property :evault
  property :monitoring
  property :response
  property :bc_insurance

  validates :hostname, presence: true
  validates :domain, presence: true
  validates :datacenter, presence: true
  validates :processor, presence: true
  validates :memory, presence: true
  validates :operating_system, presence: true
  validates :network, presence: true
end
