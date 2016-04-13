var VirtualMachinesController = Paloma.controller('VirtualMachines');

VirtualMachinesController.prototype.new = function(){
  var paloma = this;
  paloma.formPosting = false;

  $('#virtual_machine_hourly').change(function() {
    if ($(this).is(':checked')) {
      // show only hourly items
      $('#virtual_machine_bandwidth').val(1800);
      $('select option[data-recurringfee]').addClass('hidden');
      $('select option[data-hourlyfee]').removeClass('hidden');
    } else {
      // show only monthly items
      $('#virtual_machine_bandwidth').val(50367);
      $('select option[data-hourlyfee]').addClass('hidden');
      $('select option[data-recurringfee]').removeClass('hidden');
    }
    mountConflicts(this);
    chooseAlternativeOption();
    refreshSelectItems();
    refreshPriceBox(paloma);
  });
  // hide options with location dependent true
  $("[data-location-dependent-flag=1]").addClass('hidden');

  $("[data-resource]").change(function(){
    // if we de-select datacenter option
    if($('[data-resource="datacenter"]').val() == ""){
      // show all base prices
      hideDependant();
    } else {
      // here we have a data center to process
      // non dependent are data centers with base prices, they are not present
      // on conflict hash, so we need to chack this way
      var non_dependent_flag = $(this).find(':selected').data('standard-prices-flag');
      if (non_dependent_flag) {
        hideDependant();
        mountConflicts(this);
      } else {
        // otherwise we need to process the datacenter based on conflict hash
        resource = $(this).data('resource');
        hideNonDependant();
        mountConflicts(this);
      }
    }

    // after we change the datacenter, we choose the alternative options to replace
    // and refresh the conflicts for alternative options
    chooseAlternativeOption();
    refreshSelectItems();
    refreshPriceBox(paloma);
  });

  // when every select (except for datacenter) is changed
  // we need to show the options and hide for that price
  $("select[data-resource!=datacenter]").change(function(){
    selected = $(this).find("option:checked");
    non_dependent_flag = selected.data('location-dependent-flag');
    if (!non_dependent_flag) {
      hideDependant();
    } else {
      hideNonDependant();
    }
    // hide conflicts for each price
    hideConflicts(conflictHash.priceToPrice, selected.val());
    chooseAlternativeOption();
    refreshSelectItems();
    refreshPriceBox(paloma);
  });

  loadDefaultOptions(this);
};

function scrollToPriceBoxAnchor() {
  $('#price_box .category-name a').click(function(e) {
    e.preventDefault();
    anchorHref = this.getAttribute('href');
    console.log('going to... ' + anchorHref);
    $('html, body').animate({
      scrollTop: $(anchorHref).offset().top - 90
    }, 200);
  });
};

function refreshPriceBox(paloma) {
  // bind ajax to form
  if (paloma.formPosting === false) {
    paloma.formPosting = true;
    form = $('form#new_virtual_machine');
    formData = form.serialize();
    jQuery.ajax({
      type: "POST",
      url: '/virtual_machines/price_box', 
      data: formData,
      complete: function() {
        paloma.formPosting = false;
        scrollToPriceBoxAnchor();
      }
    });
  }
}
function chooseAlternativeOption() {
  // choose alternative options
  $('select:not([data-resource="datacenter"])').each(function() {
    option = $(this).find("option:checked");
    desc = option.data('item-description');
    if (desc !== undefined) {
      new_option = $(this).find('option[class!="hidden"][data-item-description="'+desc+'"]');
      if (new_option.size() === 0) {
        // TODO: improve the error message
        alert('removing option ' + desc);
        $(this).val('');
      }
      $(this).val(new_option.val());
    }
  });
}

function loadDefaultOptions(paloma) {
  // set default options after everything is loaded
  paloma.params.defaultOptions.forEach(function(id) {
    option = $('select option[value='+id+']')
    select = option.closest('select');
    select.val(option.val());
    // select.trigger('change');
  });
  $('select option[data-hourlyfee]').addClass('hidden');
  $('select option[data-recurringfee]').removeClass('hidden');
  $('#virtual_machine_hourly').trigger('change');
  mountConflicts(this);
  chooseAlternativeOption();
  refreshSelectItems();
  refreshPriceBox(paloma);
}
function hideDependant() {
  $("[data-location-dependent-flag=0]").removeClass('hidden');
  $("[data-location-dependent-flag=1]").addClass('hidden');
}

function hideNonDependant() {
  $("[data-location-dependent-flag=1]").removeClass('hidden');
}

function refreshSelectItems() {
  // hide conflicts for other items
  $('select[data-resource!=datacenter]').each(function() {
    if ($(this).val()) {
      hideConflicts(conflictHash.priceToPrice, $(this).val());
      hideConflicts(conflictHash.priceToLocation, $(this).val());
    }
  });
}

function hideConflicts(conflictHash, value){
  if(conflictHash.hasOwnProperty(value)){
    conflictHash[value].forEach(function(id){
      $('option[value="' + id + '"]').addClass('hidden');
    });
  }
}

function mountConflicts(select){
  errors = [];
  resource = $(select).data('resource');
  $("select[data-resource]").each(function() {
    resource = $(this).data('resource');
    var datacenter_id = $(this).find(':selected').data('datacenter-id');
    if (datacenter_id === undefined) {
      datacenter_id = 957095;
    }
    if (resource === "datacenter") {
      hideConflicts(conflictHash.locationToPrice, datacenter_id);
    } else {
      hideConflicts(conflictHash.priceToPrice, datacenter_id);
    }
  });
}
