class VirtualMachinesController < ApplicationController
  def index
    @virtual_machines = VirtualMachine.all
  end

  def new
    @vm = VirtualMachine.new
    @form = VirtualMachineForm.new(@vm)
    @conflict_hash = StoreHash.generate_hash.camelize_keys.to_json
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
