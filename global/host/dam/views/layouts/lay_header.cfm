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
<cfif !cgi.http_user_agent CONTAINS "iphone" AND !cgi.http_user_agent CONTAINS "ipad">
	<cfset w = 300>
<cfelse>
	<cfset w = 100>
</cfif>
<cfoutput>
	<form name="form_account" id="form_account" action="https://secure.razuna.com/account.cfm" method="post">
		<input type="hidden" name="userid" value="#session.theuserid#">
		<input type="hidden" name="hostid" value="#session.hostid#">
		<input type="hidden" name="a" value="">
	</form>
	<div style="float:left;">
		<div style="float:left;width:290px;">
			<a href="#myself#c.main&_v=#createuuid('')#">
				<cfif fileexists("#ExpandPath("../..")#global/host/logo/#session.hostid#/logo.jpg")>
					<img src="#dynpath#/global/host/logo/#session.hostid#/logo.jpg" width="200" height="29" border="0" style="padding:0px 0px 0px 15px;">
				<cfelse>
					<img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="200" height="29" border="0" style="padding:0px 0px 0px 15px;">
				</cfif>
			</a>
		</div>
		<!--- <div style="width:auto;float:left;padding-top:5px;padding-right:10px;">
			<a href="##" onclick="showwindow('#myself#c.choose_folder&folder_id=x','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("add_file"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("add_file")#">
				<button class="awesome big green">Add your files</button>
			</a>
		</div> --->
		<!--- Search --->
		<!--- <cfcachecontent name="quicksearch#w#" cachedwithin="#CreateTimeSpan(1,0,0,0)#" region="razcache"> --->
			<div style="width:auto;float:right;">
				<form name="form_simplesearch" id="form_simplesearch" onsubmit="checkentry();return false;">
				<input type="hidden" name="simplesearchthetype" id="simplesearchthetype" value="all" >
				<div style="float:left;background-color:##ddd;padding:4px;">
					<div style="float:left;">
						<input name="simplesearchtext" id="simplesearchtext" type="text" class="textbold" style="width:#w#px;" value="Quick Search">
					</div>
					<div style="float:left;padding:5px 5px 0px 5px;">
						<div style="float:left;text-decoration:none;"><a href="##" id="searchselectionlink" onclick="$('##searchselection').toggle();" class="ddicon" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#</a></div>
						<div style="float:left;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" onclick="$('##searchselection').toggle();" class="ddicon"></div>
					</div>
					<div id="searchselection" class="ddselection_header" style="left:610px;">
						<p><a href="##" onclick="selectsearchtype('all','#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#');"><div id="markall" style="float:left;padding-right:2px;"><img src="#dynpath#/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0"></div>#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#</a></p>
						<p><a href="##" onclick="selectsearchtype('img','#myFusebox.getApplicationData().defaults.trans("search_for_images")#');"><div id="markimg" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_images")#</a></p>
						<p><a href="##" onclick="selectsearchtype('doc','#myFusebox.getApplicationData().defaults.trans("search_for_documents")#');"><div id="markdoc" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_documents")#</a></p>
						<p><a href="##" onclick="selectsearchtype('vid','#myFusebox.getApplicationData().defaults.trans("search_for_videos")#');"><div id="markvid" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_videos")#</a></p>
						<p><a href="##" onclick="selectsearchtype('aud','#myFusebox.getApplicationData().defaults.trans("search_for_audios")#');"><div id="markaud" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_audios")#</a></p>
						<p><hr></p>
		<!--- 				<p><a href="##" onclick="showwindow('#myself#ajax.search_advanced','#myFusebox.getApplicationData().defaults.trans("link_adv_search")#',500,1);$('##searchselection').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("link_adv_search")#</a></p>
						<p><hr></p> --->
						<p><cfif application.razuna.whitelabel>#wl_link_search#<cfelse><a href="http://wiki.razuna.com/display/ecp/Search+and+Find+Assets" target="_blank" onclick="$('##searchselection').toggle();">Help with Search</a></cfif></p>
					</div>
					<div style="float:left;padding-left:2px;padding-top:1px;">
						<button class="awesome big green">Search</button>
						<!--- <img src="#dynpath#/global/host/dam/images/search_16.png" width="16" height="16" border="0" onclick="checkentry();" class="ddicon"> --->
					</div>
				</div>
				<div style="float:right;padding-left:20px;padding-top:8px;">
					<a href="##" onclick="loadcontent('rightside','#myself#c.search_advanced');$('##searchselection').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("link_adv_search")#</a>
				</div>
				</form>
			</div>
		<!--- </cfcachecontent> --->
	</div>
	<div style="float:right;">
		<!--- User Name with drop down --->
		<div style="width:auto;float:right;padding:7px 10px 0px 20px;">
			<!--- UserName --->
			<div style="float:left;padding-right:3px;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" class="ddicon" onclick="$('##userselection').toggle();"></div>
			<div style="float:left;min-width:150px;"><a href="##" onclick="$('##userselection').toggle();" style="text-decoration:none;" class="ddicon">#session.firstlastname#</a></div>
			<!--- UserName DropDown --->
			<div id="userselection" class="ddselection_header">
				<!--- Profile --->
				<p>
					<a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#session.theuserid#&myinfo=true','#session.firstlastname#',600,1);$('##userselection').toggle();return false;">My info</a>
					<cfif qry_detail.user_pass EQ "">
						<img width="20" height="20" border="0" src="/razuna/global/host/dam/images/active_directory_user.png">
					</cfif>
				</p>
				<p><hr></p>
				<!--- Administration --->
				<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
					<p><a href="##" onclick="loadcontent('rightside','#myself#c.admin');$('##userselection').toggle();return false;" style="width:100%;">#myFusebox.getApplicationData().defaults.trans("header_administration")#</a></p>
					<!--- showwindow('#myself#ajax.admin','#myFusebox.getApplicationData().defaults.trans("header_administration")#',900,1); --->
					<p><hr></p>
				</cfif>
				<!--- Help --->
				<p>
					<cfif application.razuna.whitelabel>
						#wl_link_support#
					<cfelse>
						<a href="https://getsatisfaction.com/razuna" target="_blank" onclick="$('##userselection').toggle();">Help / Support</a>
					</cfif>
				</p>
				<p>
					<cfif application.razuna.whitelabel>
						#wl_link_doc#
					<cfelse>
						<a href="http://wiki.razuna.com" target="_blank" onclick="$('##userselection').toggle();">Documentation (Wiki)</a>
					</cfif>
				</p>
				<p><hr></p>
				<!--- Account --->
				<cfif cgi.http_host CONTAINS "razuna.com" AND (Request.securityobj.CheckAdministratorUser() OR Request.securityobj.CheckSystemAdminUser())>
					<p><a href="##" id="account" onclick="loadcontent('rightside','#myself#ajax.account&userid=#session.theuserid#&hostid=#session.hostid#');$('##userselection').toggle();">Account Settings</a></p>
					<p><hr></p>
				</cfif>
				<!--- Languages --->
				<cfif qry_langs.recordcount NEQ 1>
					<cfloop query="qry_langs">
						<p><a href="#myself##xfa.switchlang#&thelang=#lang_name#&v=#createuuid()#">#lang_name#</a></p>
					</cfloop>
					<p><hr></p>
				</cfif>
				<!--- Feedback --->
				<cfif w EQ 100>
					<p>
						<cfif application.razuna.whitelabel>
							#wl_feedback#
						<cfelse>
							<a href="##" onClick="javascript:ZDiscussions.showDiscussionsFBW();">Feedback</a>
						</cfif>
					</p>
					<p><hr></p>
				</cfif>
				<!--- Log off --->
				<p><a href="#myself#c.logout&_v=#createuuid('')#">#myFusebox.getApplicationData().defaults.trans("logoff")#</a></p>
			</div>
		</div>
		<div style="width:auto;float:right;padding:7px 0px 0px 0px;">
			<!--- Account --->
		 	<cfif cgi.http_host CONTAINS "razuna.com" AND (Request.securityobj.CheckAdministratorUser() OR Request.securityobj.CheckSystemAdminUser())>
				<div style="float:left;padding-right:20px;">
					<a href="##" id="account" onclick="loadcontent('rightside','#myself#ajax.account&userid=#session.theuserid#&hostid=#session.hostid#');$('##userselection').toggle();">Account Settings</a>
				</div>
			</cfif>
			<!--- Feedback --->
			<cfif w EQ 300>
				<cfif application.razuna.whitelabel>
					#wl_feedback#
				<cfelse>
					<div style="float:left;"><a href="##" onClick="javascript:ZDiscussions.showDiscussionsFBW();">Feedback</a></div>
				</cfif>
			</cfif>
		</div>
	</div>
	<!--- JS --->
	<script language="javascript">
		function showaccount(){
			win = window.open('','myWin','toolbars=0,location=1,status=1,scrollbars=1,directories=0,width=650,height=600');            
			document.form_account.target='myWin';
			document.form_account.submit();
		}
		// $(function() {
		// 	var cache = {}, lastXhr;
		// 	$( "##simplesearchtext" ).autocomplete({
		// 		minLength: 3,
		// 		source: function( request, response ) {
		// 			var term = request.term;
		// 			if ( term in cache ) {
		// 				response( cache[ term ] );
		// 				return;
		// 			}

		// 			lastXhr = $.getJSON( "#myself#c.search_suggest", request, function( data, status, xhr ) {
		// 				cache[ term ] = data;
		// 				if ( xhr === lastXhr ) {
		// 					response( data );
		// 				}
		// 			});
		// 		}
		// 	});
		// });
	</script>
</cfoutput>