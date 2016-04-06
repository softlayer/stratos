class VirtualMachinesController < ApplicationController
  def index
    @virtual_machines = VirtualMachine.all
  end

  def new
    Rails.cache.write("softlayer/datacenters", Softlayer::Location::Datacenter.mask('mask[groups]').get_datacenters, expires_in: 12.hours)

    @vm = VirtualMachine.new
    @form = VirtualMachineForm.new(@vm)
  end

  def create
    @vm = VirtualMachine.new
    @form = VirtualMachineForm.new(@vm)
    if @form.validate(params[:virtual_machine])
      @form.save do |hash|
        redirect_to root_path, notice: "Virtual Machine Created Successfully"
      end
    else
      redirect_to login_path, alert: "Invalid Virtual Machine Attributes"
    end
  end
end
