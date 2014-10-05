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
<!--- Hide assetbox labels from dispalying if setting is turned on --->
<cfif !cs.show_metadata_labels>
	<style>
		.assetbox_title {display: none;}
	</style>
</cfif>

<cfif !cgi.http_user_agent CONTAINS "iphone" AND !cgi.http_user_agent CONTAINS "ipad">
	<cfset w = 300>
<cfelse>
	<cfset w = 100>
</cfif>
<cfoutput>
	<form name="form_account" id="form_account" action="https://razuna.com/account.cfm" method="post">
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
					<img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="220" height="34" border="0" style="padding:0px 0px 0px 15px;">
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
						<input name="simplesearchtext" id="simplesearchtext" type="text" class="textbold" style="width:#w#px;" value="Quick Search"  title="Uses AND for multiple keywords except if you use OR/AND or double quotes. See search help for more information.">
					</div>
					<!--- If the search selection is on we search with folder ids --->
					<cfif cs.search_selection>
						<!--- This is the selected value (should come from the defined selection of the user) --->
						<div style="float:left;padding:3px 5px 0px 5px;">
							<select data-placeholder="" class="chzn-select" name="qs_folder_id" id="qs_folder_id" style="min-width:150px;">
								<!--- <option value="0">Search in all</option> --->
								<cfloop query="qry_searchselection">
									<option value="#folder_id#"<cfif session.user_search_selection EQ "#folder_id#"> selected="selected"</cfif>>#folder_name#</option>
								</cfloop>
							</select>
						</div>
					<!--- This is the normal search --->
					<cfelse>
						<div style="float:left;padding:5px 5px 0px 5px;">
							<div style="float:left;text-decoration:none;"><a href="##" id="searchselectionlink" onclick="$('##searchselection').toggle();" class="ddicon" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#</a></div>
							<div style="float:left;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" onclick="$('##searchselection').toggle();" class="ddicon"></div>
						</div>
						<div id="searchselection" class="ddselection_header" style="left:610px;">
							<p><a href="##" onclick="selectsearchtype('all','#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#');"><div id="markall" class="markfolder" style="float:left;padding-right:2px;"><img src="#dynpath#/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0"></div>#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#</a></p>
							<p><a href="##" onclick="selectsearchtype('img','#myFusebox.getApplicationData().defaults.trans("search_for_images")#');"><div id="markimg" class="markfolder" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_images")#</a></p>
							<p><a href="##" onclick="selectsearchtype('doc','#myFusebox.getApplicationData().defaults.trans("search_for_documents")#');"><div id="markdoc" class="markfolder" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_documents")#</a></p>
							<p><a href="##" onclick="selectsearchtype('vid','#myFusebox.getApplicationData().defaults.trans("search_for_videos")#');"><div id="markvid" class="markfolder" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_videos")#</a></p>
							<p><a href="##" onclick="selectsearchtype('aud','#myFusebox.getApplicationData().defaults.trans("search_for_audios")#');"><div id="markaud" class="markfolder" style="float:left;padding-right:14px;">&nbsp;</div>#myFusebox.getApplicationData().defaults.trans("search_for_audios")#</a></p>
							<p><hr></p>
							<p><cfif application.razuna.whitelabel>#wl_link_search#<cfelse><a href="http://wiki.razuna.com/display/ecp/Search+and+Find+Assets" target="_blank" onclick="$('##searchselection').toggle();">Help with Search</a></cfif></p>
						</div>
					</cfif>
					<!--- Search button --->
					<div style="float:left;padding-left:2px;padding-top:1px;">
						<button class="awesome big green">Search</button>
						<!--- <img src="#dynpath#/global/host/dam/images/search_16.png" width="16" height="16" border="0" onclick="checkentry();" class="ddicon"> --->
					</div>
				</div>
				<div style="float:right;padding-left:20px;padding-top:8px;">
					<a href="##" onclick="loadcontent('rightside','#myself#c.search_advanced&folder_id=0');$('##searchselection').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("link_adv_search")#</a>
					<!--- <a href="##" style="padding-left:15px;" onclick="loadcontent('rightside','#myself#c.updater_tool');return false;"><strong style="color:red;">FILE RE-UPLOAD!</strong></a> --->
				</div>
				<!--- Enabled UPC search --->
				<cfif prefs.set2_upc_enabled>
					<div style="float:right;padding-left:20px;padding-top:8px;">
						<a href="##" onclick="upcsearch();return false;">#myFusebox.getApplicationData().defaults.trans("link_upc_search")#</a>
					</div>
				</cfif>
				</form>
				<!--- UPC Search Popup window --->
				<div id="popup_upcsearch" style="display:none;">
					<tr>
						<td width="1%" nowrap="true" style="font-weight:bold;"><strong>#myFusebox.getApplicationData().defaults.trans("cs_img_upc_number")#</strong></br></br>
						<textarea name="search_upc" id="search_upc" cols="42"></textarea></td>
					</tr>
				</div>
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
					<!--- RAZ-2718 Encode User's first and last name for title --->
					<a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#session.theuserid#&myinfo=true','#urlEncodedFormat(session.firstlastname)#',600,1);$('##userselection').toggle();return false;">My info</a>
					<cfif qry_detail.user_pass EQ "">
						<img width="20" height="20" border="0" src="/razuna/global/host/dam/images/active_directory_user.png">
					</cfif>
				</p>
				<p><hr></p>
				<!--- Administration. Show if user is admin or if user has access to some admin features --->
				<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser() OR !structisempty(tabaccess_struct)>
					<p><a href="##" onclick="loadcontent('rightside','#myself#c.admin');$('##userselection').toggle();return false;" style="width:100%;">#myFusebox.getApplicationData().defaults.trans("header_administration")#</a></p>
					<!--- showwindow('#myself#ajax.admin','#myFusebox.getApplicationData().defaults.trans("header_administration")#',900,1); --->
					<p><hr></p>
				</cfif>
				<!--- Help --->
				<p>
					<cfif application.razuna.whitelabel>
						#wl_link_support#
					<cfelse>
						<a href="https://help.razuna.com" target="_blank" onclick="$('##userselection').toggle();">Help / Support</a>
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
							<a href="https://help.razuna.com" target="_blank">#myFusebox.getApplicationData().defaults.trans("link_feedback")#</a>
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
			<!--- Show basket link --->
			<cfif cs.show_basket_part>
				<div style="float:left;padding-right:20px;"><a href="##" onClick="tooglefooter('0');loadcontent('thedropbasket','#myself#c.basket');">#myFusebox.getApplicationData().defaults.trans("show_basket")#</a></div>
			</cfif>
			<!--- Feedback --->
			<cfif w EQ 300>
				<cfif application.razuna.whitelabel>
					<div style="float:left;">#wl_feedback#</div>
				<cfelse>
					<div style="float:left;"><a href="https://help.razuna.com" target="_blank">#myFusebox.getApplicationData().defaults.trans("link_feedback")#</a></div>
				</cfif>
			</cfif>
		</div>
	</div>
	<!--- JS --->
	<script language="javascript">
		// Activate Chosen
		$(".chzn-select").chosen({search_contains: true});

		function showaccount(){
			win = window.open('','myWin','toolbars=0,location=1,status=1,scrollbars=1,directories=0,width=650,height=600');            
			document.form_account.target='myWin';
			document.form_account.submit();
		}
		//UPC Search
		function upcsearch(){
			$( "##popup_upcsearch" ).dialog({
				resizable: false,
				height:200,
				modal: true,
				buttons: {
				"#myFusebox.getApplicationData().defaults.trans("header_upc_search")#": function() {
					if($('##search_upc').val() == ""){
						alert("Please enter value for UPC Number");
					} else {
						$( this ).dialog( "close" );
						$('##rightside').load('index.cfm?fa=c.searchupc&thetype=all&search_upc='+$('##search_upc').val().replace(/\n/g, ","));	
					}
					
				},
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			}
		});
	};
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