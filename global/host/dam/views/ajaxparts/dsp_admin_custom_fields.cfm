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
	<cfif session.hosttype EQ 0>
		#myFusebox.getApplicationData().defaults.trans("custom_fields_desc")#<br><br>
		<cfinclude template="dsp_host_upgrade.cfm">
	<cfelse>
		#myFusebox.getApplicationData().defaults.trans("custom_fields_desc")#<br />
		<!--- Show existing fields --->
		<div id="thefields"></div>
		<br />
		<hr />
		<!--- Add a new field --->
		<form name="form_cf_add" id="form_cf_add" method="post" action="#self#" onsubmit="customfieldadd();return false;">
		<input type="hidden" name="#theaction#" value="c.custom_field_add">
		<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<th colspan="4" style="padding-bottom:10px;">#myFusebox.getApplicationData().defaults.trans("custom_fields_new")#</th>
				</tr>
				<tr>
					<td valign="top" nowrap="true">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td width="120" nowrap="true" style="padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("enabled")#</td>
								<td><input type="radio" name="cf_enabled" value="T" checked="true">#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="cf_enabled" value="F">#myFusebox.getApplicationData().defaults.trans("no")#</td>
							</tr>
							<!--- The text in the languages --->					
							<cfloop query="qry_langs">
								<tr>
									<td valign="top" width="120" nowrap="true">#lang_name#</td>
									<td><input type="text" name="cf_text_#lang_id#" size="30"></td>
								</tr>
							</cfloop>
							<tr>
								<td width="120" nowrap="true">#myFusebox.getApplicationData().defaults.trans("custom_field_for")#</td>
								<td>
									<select name="cf_show" style="width:150px;">
										<option value="all" selected="true">All</option>
										<option value="img">#myFusebox.getApplicationData().defaults.trans("only_images")#</option>
										<option value="vid">#myFusebox.getApplicationData().defaults.trans("only_videos")#</option>
										<option value="doc">#myFusebox.getApplicationData().defaults.trans("only_documents")#</option>
										<option value="aud">#myFusebox.getApplicationData().defaults.trans("only_audios")#</option>
										<option value="users">Users</option>
									</select>
								</td>
							</tr>
						</table>
					</td>
					<td valign="top" style="padding-left:10px;">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td width="120" nowrap="true">#myFusebox.getApplicationData().defaults.trans("custom_field_type")#</td>
								<td>
									<select name="cf_type" style="width:150px;">
										<option value="text" selected="true">Text</option>
										<option value="textarea">Textarea</option>
										<option value="radio">Radio Button (Yes/No)</option>
										<option value="select">Select</option>
									</select>
								</td>
							</tr>
							<!--- <tr>
								<td nowrap="true">Custom Group</td>
								<td><input type="text" name="cf_group" style="width:150px;"></td>
							</tr> --->
							<tr>
								<td nowrap="nowrap" valign="top">Select list</td>
								<td><textarea name="cf_select_list" style="width:150px;height:40px;"></textarea><br /><em>(Separate values with a coma)</em></td>
							</tr>
						</table>
					</td>
					<td valign="top" width="100%" style="padding-left:10px;">
						Groups/Users that can edit the field:<br />
						<select data-placeholder="Choose a group or user" class="chzn-select" style="width:410px;" name="cf_edit" id="cf_edit" multiple="multiple">
							<option value=""></option>
							<option value="1">System-Administrators</option>
							<option value="2">Administrators</option>
							<cfloop query="qry_groups">
								<option value="#grp_id#">#grp_name#</option>
							</cfloop>
							<cfloop query="qry_users">
								<option value="#user_id#">#user_first_name# #user_last_name# (#user_email#)</option>
							</cfloop>
						</select>
						<br />
						<em>(If left empty users can edit field according to their folder permissions)</em>
					</td>
					<td valign="top" nowrap="true">
						<input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_add")#" class="button">
					</td>
				</tr>
			</table>
		</form>
		<!--- JS --->
		<script language="JavaScript" type="text/javascript">
			// Load existing fields
			$('##thefields').load('#myself#c.custom_fields_existing');
			// Activate Chosen
			$(".chzn-select").chosen({search_contains: true});
		</script>	
	</cfif>
</cfoutput>
