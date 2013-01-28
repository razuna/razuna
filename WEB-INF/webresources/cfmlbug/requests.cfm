<cfsilent>

	<!---
		$Id: requests.cfm 2204 2012-07-23 15:27:58Z tony $
		--->

	<cfset request.page.title 	= "CFMLBug : Requests">
	<cfset request.page.heading = request.page.title>

</cfsilent><cfinclude template="inc/header.inc">
<cfinclude template="inc/nav.inc">

<div class="container cf">

	<div id="summary-panel" class="stats">
		<cfinclude template="_requests_summary.cfm">
	</div>
	
	<div class="content">
		<cfif !DebuggerIsEnabled()>
			<p>
			CFMLBug has not been fully enabled for this server.
			</p>

			<p>
			You can enable this by calling:
			<a href="http://openbd.org/manual/?/function/debuggerenable">DebuggerEnable(true)</a> in
			<a href="http://openbd.org/manual/?/app_server_cfc">/Server.cfc</a> for example.
			</p>
		<cfelse>
			<div class="refresh_btn">
				<a href="javascript:void(null);" class="j-refresh-requests">refresh</a>
			</div>
			
			<div id="requests-panel" class="panel">
				<cfinclude template="_requests_all2.cfm">
			</div>
		</cfif>
	</div><!--- end content --->

</div><!--- end container --->

<script>
inspectSession = function(id){
	$('.j-template-src').remove();
	$(this).closest('tr').after("<tr class='j-template-src'><td colspan='8'></td></tr>");

	$.get( requestRoot + "_requests_session.cfm&_cfmlbug&id=" + id,function(data){
		$('.j-template-src td').html( data );
	});
};


updateSummary = function(){
	$.get( requestRoot + "_requests_summary.cfm&_cfmlbug", function(data){
		$("#summary-panel").html( data );
		setTimeout( updateSummary, 2500 );
	});
};



$(function(){
	setTimeout( updateSummary, 2500 );

	<cfif DebuggerIsEnabled()>

	$(".j-refresh-requests").click(function(){
		$.get( requestRoot + "_requests_all.cfm&_cfmlbug", function(data){
			$("#requests-panel").html( data );
		});
	});

	//$(".filepathsize").filepaths();

	$(".j-template-file").live("click", function(){
//		$('.j-template-src').remove();
			$('.j-codewrap').remove();
		//$(this).closest('tr').after("<tr class='j-template-src'><td colspan='8'></td></tr>");
			$(this).parents('table.queries').after('<div class="j-codewrap"></div>')

		$.get( requestRoot + "_requests_file.cfm&_cfmlbug&f=" + $(this).attr("f") + "&l=" + $(this).attr("l"),function(data){
//			$('.j-template-src td').html( data );
				$('.j-codewrap').html(data)
		});
	});


	$(".j-inspect-show").live("click", function(){
		$('.j-template-src').remove();
		$(this).closest('tr').after("<tr class='j-template-src'><td colspan='8'></td></tr>");

		$.get( requestRoot + "_requests_session.cfm&_cfmlbug&id=" + $(this).attr("sessionid"),function(data){
			$('.j-template-src td').html( data );
		});
	});

	$(".kill").live("click", function(){
		$(this).addClass("stopping");
		$(this).removeClass("kill");
		$.get( requestRoot + "_requests_kill.cfm&_cfmlbug&id=" + $(this).attr("sessionid"));
	});

	</cfif>

});
</script>

<cfinclude template="inc/footer.inc">