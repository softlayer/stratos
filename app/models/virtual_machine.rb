class VirtualMachine
  def self.all
    Softlayer::Account.get_virtual_guests
  end
end
