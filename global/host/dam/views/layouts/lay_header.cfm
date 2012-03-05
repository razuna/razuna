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
	<form name="form_account" id="form_account" action="https://secure.razuna.com/account.cfm" method="post">
		<input type="hidden" name="userid" value="#session.theuserid#">
		<input type="hidden" name="hostid" value="#session.hostid#">
		<input type="hidden" name="a" value="">
	</form>
	<div style="float:left;">
		<div style="float:left;width:290px;">
			<a href="#myself#c.main">
				<cfif fileexists("#ExpandPath("../..")#global/host/logo/#session.hostid#/logo.jpg")>
					<img src="#dynpath#/global/host/logo/#session.hostid#/logo.jpg" border="0" />
				<cfelse>
					<img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="200" height="29" border="0" style="padding:3px 0px 0px 15px;">
				</cfif>
			</a>
		</div>
		<!--- Search --->
		<div style="width:auto;float:right;padding-top:7px;">
			<form name="form_simplesearch" id="form_simplesearch" onsubmit="checkentry();return false;">
			<input type="hidden" name="simplesearchthetype" id="simplesearchthetype" value="all">
			<div style="float:left;padding-top:4px;">
				<img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" border="0" class="ddicon" onclick="$('##searchselection').toggle();">
			</div>
			<div id="searchselection" class="ddselection_header">
				<p><a href="##" onclick="selectsearchtype('all');"><div id="markall" style="float:left;padding-right:2px;"><img src="#dynpath#/global/host/dam/images/arrow_selected.jpg" border="0"></div>#defaultsObj.trans("search_for_allassets")#</a></p>
				<p><a href="##" onclick="selectsearchtype('img');"><div id="markimg" style="float:left;padding-right:14px;">&nbsp;</div>#defaultsObj.trans("search_for_images")#</a></p>
				<p><a href="##" onclick="selectsearchtype('doc');"><div id="markdoc" style="float:left;padding-right:14px;">&nbsp;</div>#defaultsObj.trans("search_for_documents")#</a></p>
				<p><a href="##" onclick="selectsearchtype('vid');"><div id="markvid" style="float:left;padding-right:14px;">&nbsp;</div>#defaultsObj.trans("search_for_videos")#</a></p>
				<p><a href="##" onclick="selectsearchtype('aud');"><div id="markaud" style="float:left;padding-right:14px;">&nbsp;</div>#defaultsObj.trans("search_for_audios")#</a></p>
				<p><hr></p>
<!--- 				<p><a href="##" onclick="showwindow('#myself#ajax.search_advanced','#defaultsObj.trans("link_adv_search")#',500,1);$('##searchselection').toggle();return false;">#defaultsObj.trans("link_adv_search")#</a></p>
				<p><hr></p> --->
				<p><a href="http://wiki.razuna.com/display/ecp/Search+and+Find+Assets" target="_blank" onclick="$('##userselection').toggle();">Help with Search</a></p>
			</div>
			<div style="float:left;">
				<input name="simplesearchtext" id="simplesearchtext" type="text" class="textbold" style="width:300px;" value="Quick Search">
			</div>
			<div style="float:left;padding-left:2px;padding-top:4px;" id="searchicon">
				<img src="#dynpath#/global/host/dam/images/search_16.png" border="0" onclick="checkentry();" class="ddicon">
			</div>
			<div style="float:right;padding-left:20px;padding-top:4px;">
				<a href="##" onclick="showwindow('#myself#c.search_advanced','#defaultsObj.trans("link_adv_search")#',500,1);$('##searchselection').toggle();return false;">#defaultsObj.trans("link_adv_search")#</a>
			</div>
			</form>
		</div>
	</div>
	<div style="float:right;">
		<!--- User Name with drop down --->
		<div style="width:auto;float:right;padding:11px 10px 0px 20px;">
			<!--- UserName --->
			<div style="float:left;padding-right:3px;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" border="0" class="ddicon" onclick="$('##userselection').toggle();"></div>
			<div style="float:left;min-width:150px;"><a href="##" onclick="$('##userselection').toggle();" style="text-decoration:none;" class="ddicon">#session.firstlastname#</a></div>
			<!--- UserName DropDown --->
			<div id="userselection" class="ddselection_header">
				<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
					<p><a href="##" onclick="loadcontent('rightside','#myself#ajax.admin');$('##userselection').toggle();return false;" style="width:100%;">#defaultsObj.trans("header_administration")#</a></p>
					<!--- showwindow('#myself#ajax.admin','#defaultsObj.trans("header_administration")#',900,1); --->
					<p><hr></p>
				</cfif>
				<p><a href="https://getsatisfaction.com/razuna" target="_blank" onclick="$('##userselection').toggle();">Help / Support</a></p>
				<p><a href="http://wiki.razuna.com" target="_blank" onclick="$('##userselection').toggle();">Documentation (Wiki)</a></p>
				<cfif application.razuna.isp AND (Request.securityobj.CheckAdministratorUser() OR Request.securityobj.CheckSystemAdminUser())>
					<p><hr></p>
					<p><a href="##" id="account" onclick="loadcontent('rightside','#myself#ajax.account&userid=#session.theuserid#&hostid=#session.hostid#');$('##userselection').toggle();">Account Settings</a></p>
				</cfif>
				<cfif qry_langs.recordcount NEQ 1>
					<p><hr></p>
					<cfloop query="qry_langs">
						<p><a href="#myself##xfa.switchlang#&thelang=#lang_name#&v=#createuuid()#">#lang_name#</a></p>
					</cfloop>
				</cfif>
				<p><hr></p>
				<p><a href="#myself#c.logout&c=#createuuid()#">#defaultsObj.trans("logoff")#</a></p>
			</div>
		</div>
		<div style="width:auto;float:right;padding:11px 0px 0px 0px;">
			<!--- Account --->
		 	<cfif application.razuna.isp AND (Request.securityobj.CheckAdministratorUser() OR Request.securityobj.CheckSystemAdminUser())>
				<div style="float:left;padding-right:20px;">
					<a href="##" id="account" onclick="loadcontent('rightside','#myself#ajax.account&userid=#session.theuserid#&hostid=#session.hostid#');$('##userselection').toggle();">Account Settings</a>
				</div>
			</cfif>
			<!--- Feedback --->
			<div style="float:left;"><a href="##" onClick="feedback_widget.show();">Feedback</a></div>
		</div>	
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
				$('#searchicon').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading.gif" border="0" style="padding:0px;">');
				//loadcontent('rightside','<cfoutput>#myself#</cfoutput>c.search_simple&folder_id=0&searchtext=' + escape(theentry) + '&thetype=' + thetype);
				// We are now using POST for the search field (much more compatible then a simple laod for foreign chars)
				$('#rightside').load('<cfoutput>#myself#</cfoutput>c.search_simple', { searchtext: theentry, folder_id: 0, thetype: thetype }, function(){
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
		$('#mark' + thetype).html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/arrow_selected.jpg" border="0">');
	}
</script>
