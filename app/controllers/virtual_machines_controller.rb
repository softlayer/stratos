class VirtualMachinesController < ApplicationController
  def index
    @virtual_machines = VirtualMachine.all
  end

  def new
    @vm = VirtualMachine.new
    @form = VirtualMachineForm.new(@vm)
    @conflict_hash = StoreHash.generate_hash
    @prices = @vm.components_price
    js defaultOptions: @vm.default_options
  end

  def create
    @vm = VirtualMachine.new
    @form = VirtualMachineForm.new(@vm)
    @conflict_hash = StoreHash.generate_hash
    @prices = @vm.components_price
    js '#new', defaultOptions: @vm.default_options
    if @form.validate(params[:virtual_machine])
      @form.save do |hash|
        order_template = VirtualMachine.new(hash).template_hash
        container = Softlayer::Product::Order.verify_order(order_data: order_template)
        Softlayer::Product::Order.place_order(order_data: container)
        redirect_to root_path, notice: "Virtual Machine Created Successfully"
      end
    else
      render :new
    end
  end

  def price_box
    @vm = VirtualMachine.new(params[:virtual_machine].to_hash)
    @prices = @vm.components_price
    respond_to do |format|
      format.js { render action: "price_box" }
    end
  end

  def reboot
    vm = VirtualMachine.find(params[:id])
    vm.reboot

    respond_to do |format|
      format.js { render }
    end
  end

  def power_cycle
    vm = VirtualMachine.find(params[:id])

    if vm.running?
      vm.power_off
      @notice = "Machine turned off"
    elsif
      vm.power_on
      @notice = "Machine turned on"
    end

    respond_to do |format|
      format.js { render }
    end
  end

  def destroy
    vm = VirtualMachine.find(params[:id])
    vm.destroy

    respond_to do |format|
      format.js { render }
    end
  end
end
