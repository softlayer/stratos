class VirtualMachineForm < Reform::Form
  property :hostname
  property :domain
  property :hourly
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
  validates :hourly, presence: true
  validates :datacenter, presence: true, numericality: { only_integer: true }
  validates :guest_core, presence: true, numericality: { only_integer: true }
  validates :ram, presence: true, numericality: { only_integer: true }
  validates :os, presence: true, numericality: { only_integer: true }
  validates :guest_disk0, presence: true, numericality: { only_integer: true }
  validates :bandwidth, presence: true, numericality: { only_integer: true }
  validates :port_speed, presence: true, numericality: { only_integer: true }
  validates :monitoring, presence: true, numericality: { only_integer: true }
  validates :response, presence: true, numericality: { only_integer: true }
end
