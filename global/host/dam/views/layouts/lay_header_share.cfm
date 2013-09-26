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
	<div style="float:left;">
		<cfif shared.everyone NEQ 'T'>
			<cfset thelocation = "sharep">
		<cfelseif session.iscol EQ 'F' AND shared.everyone EQ 'T'>
			<cfset thelocation = "share">
		<cfelseif session.iscol EQ 'T' AND shared.everyone EQ 'T'>
			<cfset thelocation = "sharec">
		</cfif>
		<a href="#myself#c.#thelocation#&fid=#session.fid#">
			<cfif fileexists("#ExpandPath("../..")#global/host/logo/#session.hostid#/logo.jpg")>
				<img src="#dynpath#/global/host/logo/#session.hostid#/logo.jpg" width="220" height="34" border="0" style="padding:0px 0px 0px 5px;" />
			<cfelse>
				<img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="220" height="34" border="0" style="padding:0px 0px 0px 5px;">
			</cfif>
		</a>
	</div>
	<div style="float:right;">
		<!--- Search --->
		<div style="width:auto;float:right;padding-top:7px;padding-left:20px;padding-right:10px;">
			<form name="form_simplesearch" id="form_simplesearch" onsubmit="checkentry();return false;">
			<input type="hidden" name="fid" id="fid" value="#session.fid#">
			<input type="hidden" name="simplesearchthetype" id="simplesearchthetype" value="all">
			<div style="float:left;padding-top:4px;">
				<img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" class="ddicon" onclick="$('##searchselection').toggle();">
			</div>
			<div id="searchselection" class="ddselection_header">
				<p><a href="##" onclick="selectsearchtype('all');"><div id="markall" style="float:left;padding-right:2px;"><img src="#dynpath#/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0"></div>#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#</a></p>
				<p><a href="##" onclick="selectsearchtype('img');"><div id="markimg" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_images")#</a></p>
				<p><a href="##" onclick="selectsearchtype('doc');"><div id="markdoc" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_documents")#</a></p>
				<p><a href="##" onclick="selectsearchtype('vid');"><div id="markvid" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_videos")#</a></p>
				<p><a href="##" onclick="selectsearchtype('aud');"><div id="markaud" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_audios")#</a></p>
				<p><hr></p>
				<p><a href="http://wiki.razuna.com/display/ecp/Search+and+Find+Assets" target="_blank" onclick="$('##userselection').toggle();">Help with Search</a></p>
			</div>
			<div style="float:left;">
				<input name="simplesearchtext" id="simplesearchtext" size="25" type="text" class="textbold" style="width:150px;" value="Quick Search">
			</div>
			<div style="float:right;padding-left:2px;padding-top:4px;" id="searchicon">
				<img src="#dynpath#/global/host/dam/images/search_16.png" border="0" onclick="checkentry();" class="ddicon">
			</div>
			</form>
		</div>
		<cfif shared.everyone NEQ "T">
			<div style="width:auto;float:right;padding-top:12px;padding-left:20px;">
				<a href="#myself#c.share_logout&fid=#attributes.fid#" style="padding-left:10px;padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("logoff")#</a>
			</div>
		</cfif>
		<cfif qry_langs.recordcount NEQ 1>
			<div style="width:auto;float:right;padding-top:8px;padding-left:20px;">
				<form name="f_lang">
					<select name="app_lang" size=1 class="text" onChange="javascript:changelang('f_lang');">
						<option value="javascript:void();" selected>#myFusebox.getApplicationData().defaults.trans("changelang")#</option>
						<cfloop query="qry_langs">
						<option value="#myself##xfa.switchlang#&thelang=#lang_name#&fid=#session.fid#&to=sharep">#lang_name#</option>
						</cfloop>
					</select>
				</form>
			</div>
		</cfif>
	</div>
</cfoutput>

<script language="javascript">
	function showaccount(){
		win = window.open('','myWin','toolbars=0,location=1,status=1,scrollbars=1,directories=0,width=650,height=600');            
		document.form_account.target='myWin';
		document.form_account.submit();
	}
	// For the Quick Search
	$(document).ready(function() {
		// Store the value of the input field
		var theval = $('#simplesearchtext').val();
		// If user click on the quick search field we hide the text
		$('#simplesearchtext').click(function(){
			// Get the value of the entry field
			var theentrynow = $('#simplesearchtext').val();
			if (theentrynow == 'Quick Search'){
				$('#simplesearchtext').val('');
			}
		})
		// If the value field is empty restore the value field
		$('#simplesearchtext').blur(function(){
			// Get the current value of the field
			var thevalnow = $('#simplesearchtext').val();
			// If the current value is empty then restore it with the default value
			if ( thevalnow == ''){
				$('#simplesearchtext').val(theval);
			}
		})
	})
	function checkentry(){
		// Only allow chars
		var illegalChars = /(\*|\?)/;
		// Parse the entry
		var theentry = $('#simplesearchtext').val();
		var thetype = $('#simplesearchthetype').val();
		var thefid = $('#fid').val();
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
				$('#rightside').load('<cfoutput>#myself#</cfoutput>c.share_search', {searchtext: theentry, thetype: thetype, fid: thefid}, function(){
					$('#searchicon').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/search_16.png" border="0" onclick="checkentry();" class="ddicon">');
				});
			}
			return false;
		}
	}
	// When a search selection is clicked
	function selectsearchtype(thetype){
		$('#simplesearchthetype').val(thetype);
		$('#searchselection').toggle();
		// Remove the image in all marks
		$('#markall').html('&nbsp;');
		$('#markimg').html('&nbsp;');
		$('#markvid').html('&nbsp;');
		$('#markaud').html('&nbsp;');
		$('#markdoc').html('&nbsp;');
		// Now set the correct CSS
		$('#markall').css({'float':'left','padding-right':'14px'});
		$('#markimg').css({'float':'left','padding-right':'14px'});
		$('#markvid').css({'float':'left','padding-right':'14px'});
		$('#markaud').css({'float':'left','padding-right':'14px'});
		$('#markdoc').css({'float':'left','padding-right':'14px'});
		// Now mark the div
		$('#mark' + thetype).css({'float':'left','padding-right':'3px'});
		$('#mark' + thetype).html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0">');
	}
</script>

