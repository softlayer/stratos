// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require paloma
//= require bootstrap-sprockets
//= require_tree .

$(document).on('click', '.panel-heading span.clickable', function(e){
    var $this = $(this);
	if(!$this.hasClass('panel-collapsed')) {
		$this.parents('.panel').find('.panel-body').slideUp();
		$this.addClass('panel-collapsed');
		$this.find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
	} else {
		$this.parents('.panel').find('.panel-body').slideDown();
		$this.removeClass('panel-collapsed');
		$this.find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
	}
})

var initializePaloma = function() {
  Paloma.start();
}

$(document).on('turbolinks:load', function(){
  initializePaloma();
});

$(document).on('ajax:send', function(event, xhr){
  var link = $(event.target);
  var message = link.data('loading-message');
  var progressType = link.data('loading-progress-type');
  if (message === undefined) { message = "Loading" };
  if (progressType === undefined) { progressType = "success" };
  waitingDialog.show(message, { progressType: progressType });
});

$(document).on('ajax:complete', function(event, xhr, status){
  waitingDialog.hide();
});


document.addEventListener("turbolinks:click", function(event) {
  var $target = $(event.target);
  var loading_message = $target.data('loading-message');
  if (loading_message !== undefined) {
    var progressType = $target.data('loading-progress-type');
    if (progressType === undefined) { progressType = "success" };
    waitingDialog.show(loading_message, { progressType: progressType });
  }
})

document.addEventListener("turbolinks:before-cache", function(event) {
  waitingDialog.hide();
})
