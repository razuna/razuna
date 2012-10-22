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
	<form name="form_wl" id="form_wl" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.pref_global_wl_save">
		<div id="tabs_wl">
			<ul>
				<!--- Options --->
				<li><a href="##wl_options">Options</a></li>
				<!--- CSS --->
				<li><a href="##wl_css">CSS</a></li>
				<!--- News --->
				<li><a href="##wl_news" onclick="loadcontent('wl_news','#myself#c.wl_news');">News</a></li>
			</ul>
			<!--- Options --->
			<div id="wl_options">
				<p>#myFusebox.getApplicationData().defaults.trans("header_wl_desc")#</p>
				<!--- General title tag --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_main_html_title")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_html_title_desc")#<br />
				<div style="float:left;"><input type="text" style="width:500px;" name="wl_html_title" id="wl_html_title" value="<cfif qry_options.wl_html_title EQ "">Razuna - the open source alternative to Digital Asset Management<cfelse>#qry_options.wl_html_title#</cfif>"></div><div style="float:left;padding-left:10px;"><a href="##" onclick="usedefaults('wl_html_title');return false;">Use default</a></div>
				<div style="clear:both;"></div>
				<br />
				<!--- Login Footer --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_login")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_login_desc")#<br />
				<div style="float:left;"><textarea name="wl_login_links" id="wl_login_links" style="width:500px;height:70px;">#qry_options.wl_login_links#</textarea></div><div style="float:left;padding-left:10px;"><a href="##" onclick="usedefaults('wl_login_links');return false;">Use default</a></div>
				<div style="clear:both;"></div>
				<br />
				<!--- Main Razuna tab Bottom --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_main_razunatab")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_razunatab_desc")#<br /><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_razunatab_text")#<br />
				<input type="text" style="width:500px;" name="wl_razuna_tab_text" value="#qry_options.wl_razuna_tab_text#"><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_razunatab_content")#<br />
				<div style="float:left;"><textarea name="wl_razuna_tab_content" id="wl_razuna_tab_content" style="width:500px;height:70px;">#qry_options.wl_razuna_tab_content#</textarea></div><div style="float:left;padding-left:10px;"><a href="##" onclick="usedefaults('wl_razuna_tab_content');return false;">Use default</a></div>
				<div style="clear:both;"></div>
				<br />
				<!--- Feedback link --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_main_feedback")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_feedback_desc")#<br />
				<div style="float:left;"><textarea name="wl_feedback" id="wl_feedback" style="width:500px;height:70px;">#qry_options.wl_feedback#</textarea></div><div style="float:left;padding-left:10px;"><a href="##" onclick="usedefaults('wl_feedback');return false;">Use default</a></div>
				<div style="clear:both;"></div>
				<br />
				<!--- Dropdown menu links --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_main_links_dd")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_links_dd_desc")#<br /><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_links_dd_search")#<br />
				<div style="float:left;"><textarea name="wl_link_search" id="wl_link_search" style="width:500px;height:70px;">
					<cfif qry_options.wl_link_search EQ "">
						<a href="http://wiki.razuna.com/display/ecp/Search+and+Find+Assets" target="_blank" onclick="$('##userselection').toggle();">Help with Search</a>
					<cfelse>
						#qry_options.wl_link_search#
					</cfif>
				</textarea></div><div style="float:left;padding-left:10px;"><a href="##" onclick="usedefaults('wl_link_search');return false;">Use default</a></div>
				<div style="clear:both;"></div>
				<br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_links_dd_support")#<br />
				<div style="float:left;"><textarea name="wl_link_support" id="wl_link_support" style="width:500px;height:70px;">
					<cfif qry_options.wl_link_support EQ "">
						<a href="https://getsatisfaction.com/razuna" target="_blank" onclick="$('##userselection').toggle();">Help / Support</a>
					<cfelse>
						#qry_options.wl_link_support#
					</cfif>
				</textarea></div><div style="float:left;padding-left:10px;"><a href="##" onclick="usedefaults('wl_link_support');return false;">Use default</a></div>
				<div style="clear:both;"></div>
				<br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_links_dd_documentation")#<br />
				<div style="float:left;"><textarea name="wl_link_doc" id="wl_link_doc" style="width:500px;height:70px;">
					<cfif qry_options.wl_link_doc EQ "">
						<a href="http://wiki.razuna.com" target="_blank" onclick="$('##userselection').toggle();">Documentation (Wiki)</a>
					<cfelse>
						#qry_options.wl_link_doc#
					</cfif>
				</textarea></div><div style="float:left;padding-left:10px;"><a href="##" onclick="usedefaults('wl_link_doc');return false;">Use default</a></div>
				<div style="clear:both;"></div>
				<br /><br />
				<input type="submit" name="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("save")#">
				<br /><br />
				<div id="wlfeedback" style="display:none;font-weight:bold;color:green;padding-bottom:15px;"></div>
			</div>
			<!--- CSS --->
			<div id="wl_css">
				<textarea name="thecss" style="width:700px;height:500px;"><cfinclude template="#dynpath#/global/host/dam/views/layouts/main.css"></textarea>
				<br /><br />
				<input type="submit" name="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("save")#">
				<br /><br />
				<div id="wlfeedback2" style="display:none;font-weight:bold;color:green;padding-bottom:15px;"></div>
			</div>
			<!--- News --->
			<div id="wl_news"><img src="images/loading.gif" border="0" style="padding:10px;"></div>	
		</div>
	</form>

	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		// Tabs
		jqtabs("tabs_wl");
		// Save this form
		$("##form_wl").submit(function(e){
			// Get values
			var url = formaction("form_wl");
			var items = formserialize("form_wl");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items
			});
			// Display saved message
			$("##wlfeedback").css("display","");
			$("##wlfeedback2").css("display","");
			$("##wlfeedback3").css("display","");
			$("##wlfeedback").html('#defaultsObj.trans("saved_changes")#');
			$("##wlfeedback2").html('#defaultsObj.trans("saved_changes")#');
			$("##wlfeedback3").html('#defaultsObj.trans("saved_changes")#');
			return false;
		});
		// Defaults
		function usedefaults(what){
			switch(what){
				case 'wl_html_title':
					$('##wl_html_title').val('Razuna - the open source alternative to Digital Asset Management');
					break;
				case 'wl_login_links':
					$('##wl_login_links').val('Powered by <a href="http://razuna.com" target="_blank">Razuna</a><br />Licensed under <a href="http://www.razuna.org/whatisrazuna/licensing" target="_blank">AGPL</a><br /><a href="http://blog.razuna.com" target="_blank">Razuna Blog</a>');
					break;
				case 'wl_razuna_tab_content':
					$('##wl_razuna_tab_content').val('<a href="http://www.razuna.com" target="_blank"><img src="../../global/host/dam/images/razuna_logo-200.png" width="200" height="29" border="0" style="padding:3px 0px 0px 5px;"></a><br><a href="http://www.razuna.com" target="_blank">Razuna</a><br>Licensed under <a href="http://www.razuna.org/whatisrazuna/licensing" target="_blank">AGPL</a><br><a href="http://razuna.com" target="_blank">Razuna Hosted Platform</a> and <a href="http://razuna.org" target="_blank">Razuna Open Source</a><br><a href="http://blog.razuna.com" target="_blank">Visit the Razuna Blog for latest news.</a>');
					break;
				case 'wl_feedback':
					$('##wl_feedback').val('<a href="##" onClick="feedback_widget.show();">Feedback</a>');
					break;
				case 'wl_link_search':
					$('##wl_link_search').val('<a href="http://wiki.razuna.com/display/ecp/Search+and+Find+Assets" target="_blank" onclick="$(\'##searchselection\').toggle();">Help with Search</a>');
					break;
				case 'wl_link_support':
					$('##wl_link_support').val('<a href="https://getsatisfaction.com/razuna" target="_blank" onclick="$(\'##userselection\').toggle();">Help / Support</a>');
					break;
				case 'wl_link_doc':
					$('##wl_link_doc').val('<a href="http://wiki.razuna.com" target="_blank" onclick="$(\'##userselection\').toggle();">Documentation (Wiki)</a>');
					break;
			}
		}
	</script>
</cfoutput>