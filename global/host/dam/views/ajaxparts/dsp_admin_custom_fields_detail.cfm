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
	<!--- Add a new field --->
	<form name="form_cf_detail" id="form_cf_detail" method="post" action="#self#" onsubmit="customfieldupdate();return false;">
	<input type="hidden" name="#theaction#" value="c.custom_field_update">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="cf_id" value="#attributes.cf_id#">
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td valign="top" width="1%" nowrap="true">
				<table border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="120" nowrap="true" style="padding-right:10px;">#defaultsObj.trans("enabled")#</td>
						<td><input type="radio" name="cf_enabled" value="T"<cfif qry_field.cf_enabled EQ "T"> checked="true"</cfif>>#defaultsObj.trans("yes")# <input type="radio" name="cf_enabled" value="F"<cfif qry_field.cf_enabled EQ "F"> checked="true"</cfif>>#defaultsObj.trans("no")#</td>
					</tr>
					<!--- The text in the languages --->					
					<cfloop query="qry_langs">
						<cfset thisid = lang_id>
						<tr>
							<td valign="top" width="1%" nowrap="true">#lang_name#</td>
							<td>
								<cfloop query="qry_field">
									<cfif lang_id_r EQ thisid>
										<input type="text" name="cf_text_#thisid#" size="30" value="#cf_text#">
									</cfif>
								</cfloop>
							</td>
						</tr>
					</cfloop>
				</table>
			</td>
			<td valign="top" width="100%" style="padding-left:10px;">
				<table border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="120" nowrap="true" style="padding-right:10px;">#defaultsObj.trans("custom_field_type")#</td>
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
						<td width="120" nowrap="true" style="padding-right:10px;">#defaultsObj.trans("custom_field_for")#</td>
						<td width="100%">
							<select name="cf_show" style="width:150px;">
								<option value="all"<cfif qry_field.cf_show EQ "all"> selected="true"</cfif>>All</option>
								<option value="img"<cfif qry_field.cf_show EQ "img"> selected="true"</cfif>>#defaultsObj.trans("only_images")#</option>
								<option value="vid"<cfif qry_field.cf_show EQ "vid"> selected="true"</cfif>>#defaultsObj.trans("only_videos")#</option>
								<option value="vid"<cfif qry_field.cf_show EQ "aud"> selected="true"</cfif>>#defaultsObj.trans("only_audios")#</option>
								<option value="doc"<cfif qry_field.cf_show EQ "doc"> selected="true"</cfif>>#defaultsObj.trans("only_documents")#</option>
							</select>
						</td>
					</tr>
					<tr>
						<td width="120" nowrap="true" style="padding-right:10px;">Custom Group</td>
						<td width="100%"><input type="text" name="cf_group" style="width:150px;" value="#qry_field.cf_group#"></td>
					</tr>
					<tr>
						<td nowrap="nowrap" valign="top">Select list</td>
						<td><textarea name="cf_select_list" style="width:150px;height:40px;">#qry_field.cf_select_list#</textarea><br /><em>(Separate values with a coma)</em></td>
					</tr>
					<tr>
						<td colspan="2">ID: #attributes.cf_id#</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<div style="float:right;padding-top:10px;">
		<input type="submit" name="submit" value="#defaultsObj.trans("button_update")#" class="button">
	</div>
	</form>
</cfoutput>
