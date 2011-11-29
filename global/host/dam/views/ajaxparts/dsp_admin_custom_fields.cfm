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
	<cfif session.hosttype EQ "F">
		#defaultsObj.trans("custom_fields_desc")#<br><br>
		<cfinclude template="dsp_host_upgrade.cfm">
	<cfelse>
		#defaultsObj.trans("custom_fields_desc")#<br />
		<!--- Show existing fields --->
		<div id="thefields"></div>
		<br />
		<!--- Add a new field --->
		<form name="form_cf_add" id="form_cf_add" method="post" action="#self#" onsubmit="customfieldadd();return false;">
		<input type="hidden" name="#theaction#" value="c.custom_field_add">
		<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
		<table border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<th colspan="3" style="padding-bottom:10px;">#defaultsObj.trans("custom_fields_new")#</th>
			</tr>
			<tr>
				<td valign="top" nowrap="true">
					<table border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="120" nowrap="true" style="padding-right:10px;">#defaultsObj.trans("enabled")#</td>
							<td><input type="radio" name="cf_enabled" value="T" checked="true">#defaultsObj.trans("yes")# <input type="radio" name="cf_enabled" value="F">#defaultsObj.trans("no")#</td>
						</tr>
						<!--- The text in the languages --->					
						<cfloop query="qry_langs">
							<tr>
								<td valign="top" width="120" nowrap="true">#lang_name#</td>
								<td><input type="text" name="cf_text_#lang_id#" size="30"></td>
							</tr>
						</cfloop>
					</table>
				</td>
				<td valign="top" width="100%" style="padding-left:10px;">
					<table border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="120" nowrap="true">#defaultsObj.trans("custom_field_type")#</td>
							<td>
								<select name="cf_type" style="width:100px;">
								<option value="text" selected="true">Text</option>
								<option value="textarea">Textarea</option>
								<option value="radio">Radio Button (Yes/No)</option>
								</select>
							</td>
						</tr>
						<tr>
							<td width="120" nowrap="true">#defaultsObj.trans("custom_field_for")#</td>
							<td>
								<select name="cf_show" style="width:100px;">
								<option value="all" selected="true">All</option>
								<option value="img">#defaultsObj.trans("only_images")#</option>
								<option value="vid">#defaultsObj.trans("only_videos")#</option>
								<option value="doc">#defaultsObj.trans("only_documents")#</option>
								<option value="aud">#defaultsObj.trans("only_audios")#</option>
								</select>
							</td>
						</tr>
						<tr>
							<td nowrap="true">Custom Group</td>
							<td><input type="text" name="cf_group" style="width:99px;"></td>
						</tr>
					</table>
				</td>
				<td valign="top" nowrap="true"><input type="submit" name="submit" value="#defaultsObj.trans("button_add")#" class="button"></td>
			</tr>
		</table>
		</form>
	
		<script language="JavaScript" type="text/javascript">
			loadcontent('thefields','#myself#c.custom_fields_existing');
		</script>	
	</cfif>
</cfoutput>
