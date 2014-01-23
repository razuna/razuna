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
	<cfif !structKeyExists(variables,"cf_inline")><table border="0" cellpadding="0" cellspacing="0" width="450" class="grid"></cfif>
		<cfloop query="qry_cf">
			<!--- RAZ-2834 --->
			<cfif structKeyExists(cs,'customfield_images_metadata') AND listFindNoCase(cs.customfield_images_metadata,'#qry_cf.cf_id#',',') OR structKeyExists(cs,'customfield_audios_metadata') AND listFindNoCase(cs.customfield_audios_metadata,'#qry_cf.cf_id#',',') OR structKeyExists(cs,'customfield_videos_metadata') AND listFindNoCase(cs.customfield_videos_metadata,'#qry_cf.cf_id#',',') OR structKeyExists(cs,'customfield_files_metadata') AND listFindNoCase(cs.customfield_files_metadata,'#qry_cf.cf_id#',',') OR structKeyExists(cs,'customfield_all_metadata') AND listFindNoCase(cs.customfield_all_metadata,'#qry_cf.cf_id#',',')>
			<tr>
				<cfif !structKeyExists(variables,"cf_inline")>
					<td width="130" nowrap="true"<cfif cf_type EQ "textarea"> valign="top"</cfif>><strong>#cf_text#</strong></td>
					<td width="320">
				<cfelse>
					<td>
				</cfif>
					<!--- For text --->
					<cfif cf_type EQ "text">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<input type="text" style="width:300px;" id="cf_meta_text_#listlast(cf_id,'-')#" name="cf_meta_text_#cf_id#" value="#cf_value#" onchange="document.form#attributes.file_id#.cf_text_#listlast(cf_id,'-')#.value = document.form#attributes.file_id#.cf_meta_text_#listlast(cf_id,'-')#.value;"<cfif structKeyExists(variables,"cf_inline")> placeholder="#cf_text#"</cfif><cfif !allowed> disabled="disabled"</cfif>>
					<!--- Radio --->
					<cfelseif cf_type EQ "radio">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<input type="radio" name="cf_meta_radio_#cf_id#" id="cf_meta_radio_yes#listlast(cf_id,'-')#" value="T" onchange="document.form#attributes.file_id#.cf_radio_yes#listlast(cf_id,'-')#.checked = document.form#attributes.file_id#.cf_meta_radio_yes#listlast(cf_id,'-')#.checked;"<cfif cf_value EQ "T"> checked="true"</cfif><cfif !allowed> disabled="disabled"</cfif>>#myFusebox.getApplicationData().defaults.trans("yes")# 
						<input type="radio" name="cf_meta_radio_#cf_id#" id="cf_meta_radio_no#listlast(cf_id,'-')#" value="F" onchange="document.form#attributes.file_id#.cf_radio_no#listlast(cf_id,'-')#.checked = document.form#attributes.file_id#.cf_meta_radio_no#listlast(cf_id,'-')#.checked;"<cfif cf_value EQ "F" OR cf_value EQ ""> checked="true"</cfif><cfif !allowed> disabled="disabled"</cfif>>#myFusebox.getApplicationData().defaults.trans("no")#
					<!--- Textarea --->
					<cfelseif cf_type EQ "textarea">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<textarea name="cf_meta_textarea_#cf_id#" id="cf_meta_textarea_#listlast(cf_id,'-')#" onchange="document.form#attributes.file_id#.cf_textarea_#listlast(cf_id,'-')#.value = document.form#attributes.file_id#.cf_meta_textarea_#listlast(cf_id,'-')#.value;" style="width:310px;height:60px;"<cfif structKeyExists(variables,"cf_inline")> placeholder="#cf_text#"</cfif><cfif !allowed> disabled="disabled"</cfif>>#cf_value#</textarea>
					<!--- Select --->
					<cfelseif cf_type EQ "select">
						<!--- Variable --->
						<cfset allowed = false>
						<!--- Check for Groups --->
						<cfloop list="#session.thegroupofuser#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<!--- Check for users --->
						<cfloop list="#session.theuserid#" index="i">
							<cfif listfind(cf_edit,i)>
								<cfset allowed = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif !isnumeric(cf_edit) AND cf_edit EQ "true">
							<cfset allowed = true>
						</cfif>
						<select name="cf_meta_select_#cf_id#" id="cf_meta_select_#listlast(cf_id,'-')#" onchange="document.form#attributes.file_id#.cf_select_#listlast(cf_id,'-')#.value = document.form#attributes.file_id#.cf_meta_select_#listlast(cf_id,'-')#.value;" style="width:300px;"<cfif !allowed> disabled="disabled"</cfif>>
							<option value=""></option>
							<cfloop list="#ltrim(ListSort(cf_select_list, 'text', 'asc', ','))#" index="i">
								<option value="#i#"<cfif i EQ "#cf_value#"> selected="selected"</cfif>>#i#</option>
							</cfloop>
						</select>
					</cfif>
				</td>
			</tr>
			</cfif>   
		</cfloop>
	<cfif !structKeyExists(variables,"cf_inline")></table></cfif>
</cfoutput>