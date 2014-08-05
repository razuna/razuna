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
	<input type="hidden" name="#theaction#" value="c.wl_host_save">
		<!--- Tabs --->
		<div id="tab_wl">
			<ul>
				<!--- Options --->
				<li><a href="##wl_options">Options</a></li>
				<!--- CSS --->
				<li><a href="##wl_css">CSS</a></li>
				<!--- News --->
				<li><a href="##wl_news" onclick="loadcontent('wl_news','#myself#c.wl_news');">News</a></li>
			</ul>
			<!--- Content --->
			<div id="wl_options">
				<p>#myFusebox.getApplicationData().defaults.trans("header_wl_desc")#</p>
				<!--- General title tag --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_main_html_title")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_html_title_desc")#<br />
				<div style="float:left;"><input type="text" style="width:500px;" name="wl_html_title_#session.hostid#" id="wl_html_title" value="#qry_wl.wl_html_title#"></div>
				<div style="clear:both;"></div>
				<br />
				<!--- Login Footer --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_login")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_login_desc")#<br />
				<div style="float:left;"><textarea name="wl_login_links_#session.hostid#" id="wl_login_links" style="width:500px;height:70px;">#qry_wl.wl_login_links#</textarea></div>
				<div style="clear:both;"></div>
				<br>
				<hr>
				<br />
				<!--- Main page Videos --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_main_video")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_video_desc")#<br />
				<div style="float:left;"><textarea name="wl_main_static_#session.hostid#" id="wl_main_static" style="width:500px;height:70px;">#qry_wl.wl_main_static#</textarea></div>
				<div style="clear:both;"></div>
				<br>
				<hr>
				<br />
				<!--- Main Razuna tab Bottom --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_main_razunatab")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_razunatab_desc")#<br /><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_razunatab_text")#<br />
				<input type="text" style="width:500px;" name="wl_razuna_tab_text_#session.hostid#" value="#qry_wl.wl_razuna_tab_text#"><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_razunatab_content")#<br />
				<div style="float:left;"><textarea name="wl_razuna_tab_content_#session.hostid#" id="wl_razuna_tab_content" style="width:500px;height:70px;">#qry_wl.wl_razuna_tab_content#</textarea></div>
				<div style="clear:both;"></div>
				<br>
				<hr>
				<br />
				<!--- Feedback link --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_main_feedback")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_feedback_desc")#<br />
				<div style="float:left;"><textarea name="wl_feedback_#session.hostid#" id="wl_feedback" style="width:500px;height:70px;">#qry_wl.wl_feedback#</textarea></div>
				<div style="clear:both;"></div>
				<br />
				<!--- Dropdown menu links --->
				<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_main_links_dd")#</strong><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_links_dd_desc")#<br /><br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_links_dd_search")#<br />
				<div style="float:left;"><textarea name="wl_link_search_#session.hostid#" id="wl_link_search" style="width:500px;height:70px;">#qry_wl.wl_link_search#</textarea></div>
				<div style="clear:both;"></div>
				<br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_links_dd_support")#<br />
				<div style="float:left;"><textarea name="wl_link_support_#session.hostid#" id="wl_link_support" style="width:500px;height:70px;">#qry_wl.wl_link_support#</textarea></div>
				<div style="clear:both;"></div>
				<br />
				#myFusebox.getApplicationData().defaults.trans("header_wl_main_links_dd_documentation")#<br />
				<div style="float:left;"><textarea name="wl_link_doc_#session.hostid#" id="wl_link_doc" style="width:500px;height:70px;">#qry_wl.wl_link_doc#</textarea></div>
				<div style="clear:both;"></div>
				<br>
				<hr>
				<br>
				#myFusebox.getApplicationData().defaults.trans("wl_show_recent_updates_desc")#<br/><br/>
				<strong>Show list of most recently updated assets</strong><br />
				<input type="radio" value="true" name="wl_show_updates_#session.hostid#"<cfif qry_wl.wl_show_updates> checked="checked"</cfif>> #myFusebox.getApplicationData().defaults.trans("show")#<br />
				<input type="radio" value="false" name="wl_show_updates_#session.hostid#"<cfif !qry_wl.wl_show_updates> checked="checked"</cfif>> #myFusebox.getApplicationData().defaults.trans("hide")#
				<div style="clear:both;"></div>
				<br /><br />
				<input type="submit" name="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("save")#">
				<br /><br />
				<div id="wlfeedback" style="display:none;font-weight:bold;color:green;padding-bottom:15px;"></div>
			</div>
			<!--- CSS --->
			<div id="wl_css">
				#myFusebox.getApplicationData().defaults.trans("wl_css_desc")# <a href="#dynpath#/global/host/dam/views/layouts/main.css" target="_blank">Razuna CSS</a>.
				<br /><br />
				<textarea name="wl_thecss_#session.hostid#" style="width:700px;height:500px;">#qry_wl.wl_thecss#</textarea>
				<br /><br />
				<input type="submit" name="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("save")#">
				<br /><br />
				<div id="wlfeedback2" style="display:none;font-weight:bold;color:green;padding-bottom:15px;"></div>
			</div>
			<!--- NEWS --->
			<div id="wl_news"></div>
		</div>
	</form>
</cfoutput>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	$("#tab_wl").tabs();
	// Save this form
	$("#form_wl").submit(function(e){
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
		$("#wlfeedback").css("display","");
		$("#wlfeedback2").css("display","");
		$("#wlfeedback3").css("display","");
		$("#wlfeedback").html('<cfoutput>#myFusebox.getApplicationData().defaults.trans("saved_change")#</cfoutput>');
		$("#wlfeedback2").html('<cfoutput>#myFusebox.getApplicationData().defaults.trans("saved_change")#</cfoutput>');
		$("#wlfeedback3").html('<cfoutput>#myFusebox.getApplicationData().defaults.trans("saved_change")#</cfoutput>');
		return false;
	});
</script>