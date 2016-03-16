class VirtualMachinesController < ApplicationController
  def index
    @virtual_machines = VirtualMachine.all
  end
end