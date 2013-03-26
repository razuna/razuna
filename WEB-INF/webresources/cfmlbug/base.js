// hide the inspect panels on profiler

$(document).ready(function() {
	
	$(".inspect").hide();
	$(".screenshot").hide();
	
	$(".inspect-show").live("click", function() {
		var renderElement = $(this).closest("tr").next(".inspect");
		
		if(renderElement.is(":visible")) {
			renderElement.slideUp(100);
		} else {
			renderElement.slideDown(100);
		}
		
	});
	
	$(".show-window").click(function() {
		$(".screenshot").toggle();
	});

});