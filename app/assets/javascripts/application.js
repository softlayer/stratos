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

// $(window).scroll(function(e){
//   var $el = $('#price_box');
//   var isPositionFixed = ($el.css('position') == 'fixed');
//   var priceBoxWidth = $el.width();
//   if ($(this).scrollTop() > 75 && !isPositionFixed){
//     $('#price_box').css({'position': 'fixed', 'top': '63px' });
//     $('#price_box').width(priceBoxWidth);
//   }
//   if ($(this).scrollTop() < 75 && isPositionFixed)
//   {
//     $('#price_box').css({'position': 'static', 'top': '0px'});
//     $('#price_box').width('100%');
//   }
// });

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

$(document).on('page:load', function(){
  if ($('.js-paloma-hook').data('id') != parseInt(Paloma.engine._request.id)) {
    initializePaloma();
  }
});

$(document).ready(function(){
  initializePaloma();
});
