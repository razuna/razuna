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
<style>
	td {padding-top:20px;}
</style>
<cfoutput>
	<div id="container">
		<div align="left">
			<a href="##" onclick="showwindow('#myself#c.metadata_choose_folder&what=#attributes.what#&file_id=#attributes.file_id#','#myFusebox.getApplicationData().defaults.trans("choose_location")#',600,2);"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("select_folder")#</button></a>
		</div>
		<div style="clear:both;"></div>
		<div style="width:auto;float:right;height:60px;margin-top:-30px;">
			<div style="float:left;padding:4px;">
				<div style="float:left;">
					<input name="searchtext" id="searchtext" type="text" class="textbold" style="width:250px;" value="">
				</div>
				<div style="float:left;padding-left:2px;padding-top:1px;">
					<button class="awesome big green" onclick="copy_meta();return false;">Search</button>
				</div>
			</div>
		</div>
		<div style="clear:both;"></div>
		<form  name="form#attributes.file_id#" id="form#attributes.file_id#" action="#myself#" method="post" onsubmit="filesubmit();return false;">
			<input type="hidden" name="#theaction#" value="#xfa.save#">
			<input type="hidden" name="file_id" value="#attributes.file_id#">
			<div id="result"></div>
		</form>
		<div id="statusconvertreditions" style="padding:10px;color:green;background-color:##FFFFE0;visibility:hidden;"></div>
		<div id="statusrenditionconvertdummy"></div>
	</div>
</cfoutput>
<script language="javascript" type="text/javascript">
	function copy_meta(){
		// Only allow chars
		var illegalChars = /(\*|\?)/;
		// Parse the entry
		var theentry = $('#searchtext').val();
		var thetype = '<cfoutput>#attributes.what#</cfoutput>';
		var thefid = '<cfoutput>#attributes.file_id#</cfoutput>';
		if (theentry == "" | theentry == "Quick Search"){
			return false;
		}
		else {
			// get the first position
			var p1 = theentry.substr(theentry,1);
			// Now check
			if (illegalChars.test(p1)){
				alert('The first character of your search string is an illegal one. Please remove it!');
			}
			else {
				$('#searchicon').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading.gif" border="0" style="padding:0px;" width="16" height="16">');
				$('#result').load('<cfoutput>#myself#</cfoutput>c.copy_metadata_do', {searchtext: theentry, thetype: thetype, fid: thefid}, function(){
					$('#searchicon').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/search_16.png" border="0" onclick="checkentry();" class="ddicon">');
				});
			}
			return false;
		}
	}
	function completed(){
		document.getElementById('statusconvertreditions').style.visibility = "visible";
		$("#statusconvertreditions").html('The metadata has been saved to the assets successfully.');
		$("#statusconvertreditions").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	}
</script>
