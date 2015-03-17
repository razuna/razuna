<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
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
		
	
