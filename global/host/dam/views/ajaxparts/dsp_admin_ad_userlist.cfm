<cfoutput>
	<div id="container">
		<div>
			<p>#myFusebox.getApplicationData().defaults.trans("ad_userlist_header")#</p>
			<p><hr /></p>
		</div>
		<div style="clear:both;"></div>
		<div style="width:auto;float:right;height:60px;">
			<div style="float:left;padding:4px;">
				<div style="float:left;">
					<input name="searchtext" id="searchtext" type="text" class="textbold" style="width:250px;" value="" placeholder="#myFusebox.getApplicationData().defaults.trans("ldap_userfilter_placeholder")#">
				</div>
				<div style="float:left;padding-left:2px;padding-top:1px;">
					<button class="awesome big green" onclick="filter_user();return false;">#myFusebox.getApplicationData().defaults.trans("Filter")#</button>
				</div>
			</div>
		</div>
		<div style="clear:both;"></div>
		<div id="result"></div>
	</div>
</cfoutput>

<script type="text/javascript">
	$(document).ready(function(){
		var theentry = $('#searchtext').val();
		$('#result').load('<cfoutput>#myself#</cfoutput>c.ad_server_users_list_do', {searchtext: theentry}, function(){
				//$('#searchicon').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/search_16.png" border="0" onclick="checkentry();" class="ddicon">');
			});
	});
	function filter_user(){
		var theentry = $('#searchtext').val();
		
		//$('#searchicon').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading.gif" border="0" style="padding:0px;" width="16" height="16">');
		$('#result').load('<cfoutput>#myself#</cfoutput>c.ad_server_users_list_do', {searchtext: theentry}, function(){
			//$('#searchicon').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/search_16.png" border="0" onclick="checkentry();" class="ddicon">');
		});
		
		return false;
		
	}
</script>
		
	
