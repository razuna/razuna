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
	<div style="height:350px;">
		<!--- Add a new field --->
		<form name="form_cf_detail" id="form_cf_detail" method="post" action="#self#" onsubmit="customfieldupdate();return false;">
		<input type="hidden" name="#theaction#" value="c.custom_field_update">
		<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
		<input type="hidden" name="cf_id" value="#attributes.cf_id#">
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<td valign="top" width="1%" nowrap="true">
					<table border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="120" nowrap="true" style="padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("enabled")#</td>
							<td><input type="radio" name="cf_enabled" value="T"<cfif qry_field.cf_enabled EQ "T"> checked="true"</cfif>>#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="cf_enabled" value="F"<cfif qry_field.cf_enabled EQ "F"> checked="true"</cfif>>#myFusebox.getApplicationData().defaults.trans("no")#</td>
						</tr>
						<!--- The text in the languages --->					
						<cfloop query="qry_langs">
							<cfset thisid = lang_id>
							<tr>
								<td width="1%" nowrap="true">#lang_name#</td>
								<td>
									<cfloop query="qry_field">
										<cfif lang_id_r EQ thisid>
											<input type="text" name="cf_text_#thisid#" size="30" value="#cf_text#">
										</cfif>
									</cfloop>
								</td>
							</tr>
						</cfloop>
						<tr>
							<td width="120" nowrap="true" style="padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("custom_field_for")#</td>
							<td width="100%">
								<select name="cf_show" style="width:150px;">
									<option value="all"<cfif qry_field.cf_show EQ "all"> selected="true"</cfif>>All</option>
									<option value="img"<cfif qry_field.cf_show EQ "img"> selected="true"</cfif>>#myFusebox.getApplicationData().defaults.trans("only_images")#</option>
									<option value="vid"<cfif qry_field.cf_show EQ "vid"> selected="true"</cfif>>#myFusebox.getApplicationData().defaults.trans("only_videos")#</option>
									<option value="aud"<cfif qry_field.cf_show EQ "aud"> selected="true"</cfif>>#myFusebox.getApplicationData().defaults.trans("only_audios")#</option>
									<option value="doc"<cfif qry_field.cf_show EQ "doc"> selected="true"</cfif>>#myFusebox.getApplicationData().defaults.trans("only_documents")#</option>
									<option value="users"<cfif qry_field.cf_show EQ "users"> selected="true"</cfif>>Users</option>
								</select>
							</td>
						</tr>
						<tr>
							<td colspan="2">ID: #attributes.cf_id#</td>
						</tr>
					</table>
				</td>
				<td valign="top" width="100%" style="padding-left:10px;">
					<table border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="120" nowrap="true" style="padding-right:10px;">#myFusebox.getApplicationData().defaults.trans("custom_field_type")#</td>
							<td width="100%">
								<select name="cf_type" style="width:150px;">
									<option value="text"<cfif qry_field.cf_type EQ "text"> selected="true"</cfif>>Text</option>
									<option value="textarea"<cfif qry_field.cf_type EQ "textarea"> selected="true"</cfif>>Textarea</option>
									<option value="radio"<cfif qry_field.cf_type EQ "radio"> selected="true"</cfif>>Radio Button (Yes/No)</option>
									<option value="select"<cfif qry_field.cf_type EQ "select"> selected="true"</cfif>>Select</option>
								</select>
							</td>
						</tr>
						<tr>
							<td nowrap="nowrap" valign="top">Select list</td>
							<td><textarea name="cf_select_list" style="width:150px;height:40px;">#qry_field.cf_select_list#</textarea><br /><em>(Separate values with a coma)</em></td>
						</tr>
						<tr>
							<td width="120" nowrap="true" style="padding-right:10px;" valign="top">Show in form</td>
							<td width="100%"><input type="radio" name="cf_in_form" value="true"<cfif qry_field.cf_in_form> checked="checked"</cfif>> #myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="cf_in_form" value="false"<cfif !qry_field.cf_in_form> checked="checked"</cfif>> #myFusebox.getApplicationData().defaults.trans("no")#<br /><em>(only applies to "users" fields and the request form)</em></td>
						</tr>
						<!--- <tr>
							<td width="120" nowrap="true" style="padding-right:10px;">Custom Group</td>
							<td width="100%"><input type="text" name="cf_group" style="width:150px;" value="#qry_field.cf_group#"></td>
						</tr> --->
					</table>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					Groups/Users that can edit the field:<br />
					<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="cf_edit" id="cf_edit_#attributes.cf_id#" multiple="multiple">
						<option value=""></option>
						<option value="1"<cfif listfind(qry_field.cf_edit,1)> selected="selected"</cfif>>System-Administrators</option>
						<option value="2"<cfif listfind(qry_field.cf_edit,2)> selected="selected"</cfif>>Administrators</option>
						<cfloop query="qry_groups">
							<option value="#grp_id#"<cfif listfind(qry_field.cf_edit,grp_id)> selected="selected"</cfif>>#grp_name#</option>
						</cfloop>
						<cfloop query="qry_users">
							<option value="#user_id#"<cfif listfind(qry_field.cf_edit,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
						</cfloop>
					</select>
					<br />
					<em>(If left empty users can edit field according to their folder permissions)</em>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					XMP path to use for parsing: <br/>
					<input type="text" name="cf_xmp_path" size="30" value="#qry_field.cf_xmp_path#" style="width:490px;">
				</td>
			</tr>
		</table>
		<div style="float:right;padding-top:10px;">
			<input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_update")#" class="button">
		</div>
		</form>
	</div>
</cfoutput>
<script type="text/javascript">
	// Activate Chosen
	$(".chzn-select").chosen({search_contains: true});
</script>
