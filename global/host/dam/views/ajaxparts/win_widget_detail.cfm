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
<cfparam default="0" name="attributes.widget_id">

<cfoutput>
	<div id="widget_tab">
		<ul>
			<li><a href="##widget_start" onclick="$('##form_widget').submit();">#myFusebox.getApplicationData().defaults.trans("widget")#</a></li>
			<li><a href="##widget_settings" onclick="$('##form_widget').submit();">#myFusebox.getApplicationData().defaults.trans("widget_settings")#</a></li>
			<li><a href="##widget_code" onclick="$('##form_widget').submit();">#myFusebox.getApplicationData().defaults.trans("widget")# Code</a></li>
		</ul>
		<form name="form_widget" id="form_widget" method="post" action="#self#">
		<input type="hidden" name="#theaction#" value="c.widget_update">
		<input type="hidden" name="folder_id" value="#attributes.folder_id#">
		<input type="hidden" name="col_id" value="#attributes.col_id#">
		<input type="hidden" name="widget_id" id="widget_id" value="#attributes.widget_id#">
		<!--- Widget --->
		<div id="widget_start">
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<tr>
					<td nowrap="nowrap" width="1%"><strong>#myFusebox.getApplicationData().defaults.trans("widget_name")#</strong></td>
					<td><input type="text" name="widget_name" id="widget_name" style="width:300px;" class="textbold" value="#qry_widget.widget_name#"></td>
				</tr>
				<tr>
					<td nowrap="nowrap" valign="top"><strong>#myFusebox.getApplicationData().defaults.trans("description")#</strong></td>
					<td><textarea name="widget_description" style="width:300px;height:50px;">#qry_widget.widget_description#</textarea></td>
				</tr>
				<tr>
					<td nowrap="nowrap" colspan="2"><strong>#myFusebox.getApplicationData().defaults.trans("widget_access_header")#</strong></td>
				</tr>
				<tr>
					<td colspan="2">
						<table border="0" width="100%" class="grid">
							<tr>
								<td valign="top" align="center"><input type="radio" name="widget_permission" value="f"<cfif qry_widget.widget_id EQ "" OR qry_widget.widget_permission EQ "f"> checked="checked"</cfif>></td>
								<td>#myFusebox.getApplicationData().defaults.trans("widget_access_public")#</td>
							</tr>
							<tr>
								<td valign="top" align="center"><input type="radio" name="widget_permission" value="g"<cfif qry_widget.widget_permission EQ "g"> checked="checked"</cfif>></td>
								<td>#myFusebox.getApplicationData().defaults.trans("widget_access_permissions")#</td>
							</tr>
							<tr>
								<td valign="top" align="center"><input type="radio" name="widget_permission" value="p"<cfif qry_widget.widget_permission EQ "p"> checked="checked"</cfif>></td>
								<td>#myFusebox.getApplicationData().defaults.trans("widget_access_password")#</td>
							</tr>
							<tr>
								<td></td>
								<td>#myFusebox.getApplicationData().defaults.trans("password")# <input type="text" name="widget_password" style="width:300px;" class="textbold" value="#qry_widget.widget_password#"></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</div>
		<!--- widget_settings --->
		<div id="widget_settings">
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<!--- Widget Style --->
				<tr>
					<td colspan="2"><strong>#myFusebox.getApplicationData().defaults.trans("widget_style")#</strong></td>
				</tr>
				<tr>
					<td colspan="2">
						<table border="0" width="100%">
							<tr>
								<td valign="top"><input type="radio" name="widget_style" value="d"<cfif qry_widget.widget_id EQ "" OR qry_widget.widget_style EQ "d"> checked="checked"</cfif>></td>
								<td>#myFusebox.getApplicationData().defaults.trans("widget_style_default")#</td>
							</tr>
							<tr>
								<td valign="top"><input type="radio" name="widget_style" value="s"<cfif qry_widget.widget_style EQ "s"> checked="checked"</cfif>></td>
								<td>#myFusebox.getApplicationData().defaults.trans("widget_style_slideshow")#</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr class="list">
					<td colspan="2"></td>
				</tr>
				<!--- Download Thumbnail --->
				<tr>
					<td colspan="2"><strong>#myFusebox.getApplicationData().defaults.trans("share_allow_download_thumbnail")#</strong></td>
				</tr>
				<tr>
					<td colspan="2">#myFusebox.getApplicationData().defaults.trans("share_allow_download_thumbnail_desc")#</td>
				</tr>
				<tr>
					<td nowrap="nowrap" valign="top">#myFusebox.getApplicationData().defaults.trans("share_allow_download_thumbnail")#</td>
					<td><input type="radio" value="T" name="widget_dl_thumb" id="widget_dl_thumb"<cfif qry_widget.widget_id EQ "" OR qry_widget.widget_dl_thumb EQ "t"> checked="checked"</cfif>>#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" value="F" name="widget_dl_thumb" id="widget_dl_thumb"<cfif qry_widget.widget_dl_thumb EQ "f"> checked="checked"</cfif>>#myFusebox.getApplicationData().defaults.trans("no")#
						<br />
						<cfif attributes.col_id NEQ "">
							<a href="##" onclick="resetdl('widget_dl_org','widget_dl_thumb','#attributes.col_id#','colreset');return false;">#myFusebox.getApplicationData().defaults.trans("share_folder_download_reset")#</a>
						<cfelse>
							<a href="##" onclick="resetdl('widget_dl_org','widget_dl_thumb','#attributes.folder_id#','wreset');return false;">#myFusebox.getApplicationData().defaults.trans("share_folder_download_reset")#</a>
						</cfif>
					<div id="wreset_thumb" style="color:green;font-weight:bold;padding-top:5px;"></div>
					</td>
				</tr>
				<tr class="list">
					<td colspan="2"></td>
				</tr>
				<!--- Download Original --->
				<tr>
					<td colspan="2"><strong>#myFusebox.getApplicationData().defaults.trans("share_allow_download_original")#</strong></td>
				</tr>
				<tr>
					<td colspan="2">#myFusebox.getApplicationData().defaults.trans("share_allow_download_desc")#</td>
				</tr>
				<tr>
					<td nowrap="nowrap" valign="top">#myFusebox.getApplicationData().defaults.trans("share_allow_download_original")#</td>
					<td><input type="radio" value="T" name="widget_dl_org" id="widget_dl_org"<cfif qry_widget.widget_dl_org EQ "T"> checked="checked"</cfif>>#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" value="F" name="widget_dl_org" id="widget_dl_org"<cfif qry_widget.widget_id EQ "" OR qry_widget.widget_dl_org EQ "F"> checked="checked"</cfif>>#myFusebox.getApplicationData().defaults.trans("no")#
					<br />
					<cfif attributes.col_id NEQ "">
						<a href="##" onclick="resetdl('widget_dl_org','widget_dl_thumb','#attributes.col_id#','colreset');return false;">#myFusebox.getApplicationData().defaults.trans("share_folder_download_reset")#</a>
					<cfelse>
						<a href="##" onclick="resetdl('widget_dl_org','widget_dl_thumb','#attributes.folder_id#','wreset');return false;">#myFusebox.getApplicationData().defaults.trans("share_folder_download_reset")#</a>
					</cfif>
					<div id="wreset_org" style="color:green;font-weight:bold;padding-top:5px;"></div>
					</td>
				</tr>
				<!--- Upload --->
				<tr>
					<td colspan="2" class="list"></td>
				</tr>
				<tr>
					<td colspan="2"><strong>#myFusebox.getApplicationData().defaults.trans("share_allow_upload")#</strong></td>
				</tr>
				<tr>
					<td colspan="2">#myFusebox.getApplicationData().defaults.trans("share_allow_upload_desc")#</td>
				</tr>
				<tr>
					<td>#myFusebox.getApplicationData().defaults.trans("share_allow_upload")#</td>
					<td><input type="radio" value="t" name="widget_uploading"<cfif qry_widget.widget_uploading EQ "t"> checked="checked"</cfif>>#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" value="f" name="widget_uploading"<cfif qry_widget.widget_id EQ "" OR qry_widget.widget_uploading EQ "f"> checked="checked"</cfif>>#myFusebox.getApplicationData().defaults.trans("no")#</td>
				</tr>
			</table>
		</div>
		<!--- widget_code --->
		<div id="widget_code">
			<strong>Link to Widget</strong><br />
			<input type="text" style="width:450px;" id="widget_text" readonly="readonly" value="#session.thehttp##cgi.http_host##cgi.script_name#?fa=c.w&wid=#attributes.widget_id#"> <a href="#session.thehttp##cgi.http_host##cgi.script_name#?fa=c.w&wid=#attributes.widget_id#" target="_blank" id="widget_link">Jump to</a><br />
			<strong>Embed Code</strong><br />
			<textarea id="widget_textarea" style="width:450px;height:100px;" readonly="readonly"><iframe frameborder="0" src="#session.thehttp##cgi.http_host##cgi.script_name#?fa=c.w&wid=#attributes.widget_id#" scrolling="auto" width="100%" height="500"></iframe></textarea>
		</div>
		<!--- Loading Bars --->
		<div style="float:left;padding:10px;color:green;font-weight:bold;display:none;" id="widgetstatus"></div>
		<div style="float:right;padding:10px;"><input type="submit" name="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>
		</form>
	</div>
	<!--- JS --->
	<script language="JavaScript" type="text/javascript">
		// Create Tabs
		jqtabs("widget_tab");
		// Submit Form
		$("##form_widget").submit(function(e){
			// Check for widget name
			var widgetname = $('##widget_name').val();
			// If empty
			if (widgetname == ''){
				alert("Please enter a name for your widget!");
				return false;
			}
			else {
				// Get values
				var url = formaction("form_widget");
				var items = formserialize("form_widget");
				// Submit Form
				$.ajax({
					type: "POST",
					url: url,
				   	data: items,
				   	success: function(data){
						$("##widgetstatus").html('#JSStringFormat(myFusebox.getApplicationData().defaults.trans("success"))#');
						$("##widgetstatus").animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
						widgetreload(data);
				   	}
				});
				return false;
			}
		});
		// Reload widget list
		function widgetreload(data){
			// Trim the returning ID
			var trimmed = data.replace(/^\s+|\s+$/g, '');
			// Update the textarea field
			var thetextarea = '&lt;iframe frameborder="0" src="#session.thehttp##cgi.http_host##cgi.script_name#?fa=c.w&wid=' + trimmed + '" scrolling="auto" width="100%" height="500"></iframe>';
			var thetext = '#session.thehttp##cgi.http_host##cgi.script_name#?fa=c.w&wid=' + trimmed;
			$('##widget_textarea').html(thetextarea);
			$('##widget_text').val(thetext);
			$('##widget_link').attr('href',thetext);
			$('##widget_id').val(trimmed);
			// Update background widget list
			$('##widgets').load('#myself#c.widgets&col_id=#attributes.col_id#&folder_id=#attributes.folder_id#');
		}
	</script>	
</cfoutput>
	
