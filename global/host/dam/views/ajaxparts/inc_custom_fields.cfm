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
	<!---RAZ-2834:: Assign the custom field customized --->
	<cfset custom_fields = "">
	<cfif !structKeyExists(variables,"cf_inline")><table border="0" cellpadding="0" cellspacing="0" width="450" class="grid"></cfif>
		<cfloop query="qry_cf">
			<cfif ! (qry_cf.cf_show EQ attributes.cf_show OR qry_cf.cf_show EQ 'all')>
				<cfcontinue>
			</cfif>
			<cfset custom_fields = listappend(custom_fields,"#cs.customfield_images_metadata#",',')>
			<cfset custom_fields = listappend(custom_fields,"#cs.customfield_audios_metadata#",',')>
			<cfset custom_fields = listappend(custom_fields,"#cs.customfield_videos_metadata#",',')>
			<cfset custom_fields = listappend(custom_fields,"#cs.customfield_files_metadata#",',')>
			<cfset custom_fields = listappend(custom_fields,"#cs.customfield_all_metadata#",',')>
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
						<input type="text" style="width:300px;" id="cf_text_#listlast(cf_id,'-')#" name="cf_#cf_id#" value="#cf_value#" <cfif listFindNoCase(custom_fields,'#qry_cf.cf_id#',',')>onchange="document.form#attributes.file_id#.cf_meta_text_#listlast(cf_id,'-')#.value = document.form#attributes.file_id#.cf_text_#listlast(cf_id,'-')#.value;" </cfif>  <cfif structKeyExists(variables,"cf_inline")> placeholder="#cf_text#"</cfif><cfif !allowed> disabled="disabled"</cfif>>
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
						<input type="radio" name="cf_#cf_id#" id="cf_radio_yes#listlast(cf_id,'-')#" value="T" <cfif listFindNoCase(custom_fields,'#qry_cf.cf_id#',',')> onchange="document.form#attributes.file_id#.cf_meta_radio_yes#listlast(cf_id,'-')#.checked = document.form#attributes.file_id#.cf_radio_yes#listlast(cf_id,'-')#.checked;" </cfif> <cfif cf_value EQ "T"> checked="true"</cfif><cfif !allowed> disabled="disabled"</cfif>>#myFusebox.getApplicationData().defaults.trans("yes")# 
						<input type="radio" name="cf_#cf_id#" id="cf_radio_no#listlast(cf_id,'-')#" value="F" <cfif listFindNoCase(custom_fields,'#qry_cf.cf_id#',',')> onchange="document.form#attributes.file_id#.cf_meta_radio_no#listlast(cf_id,'-')#.checked = document.form#attributes.file_id#.cf_radio_no#listlast(cf_id,'-')#.checked;" </cfif> <cfif cf_value EQ "F" OR cf_value EQ ""> checked="true"</cfif><cfif !allowed> disabled="disabled"</cfif>>#myFusebox.getApplicationData().defaults.trans("no")#
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
						<textarea name="cf_#cf_id#" id="cf_textarea_#listlast(cf_id,'-')#" <cfif listFindNoCase(custom_fields,'#qry_cf.cf_id#',',')> onchange="document.form#attributes.file_id#.cf_meta_textarea_#listlast(cf_id,'-')#.value = document.form#attributes.file_id#.cf_textarea_#listlast(cf_id,'-')#.value;" </cfif> style="width:310px;height:60px;"<cfif structKeyExists(variables,"cf_inline")> placeholder="#cf_text#"</cfif><cfif !allowed> disabled="disabled"</cfif>>#cf_value#</textarea>
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
						<select name="cf_#cf_id#" id="cf_select_#listlast(cf_id,'-')#" <cfif listFindNoCase(custom_fields,'#qry_cf.cf_id#',',')> onchange="document.form#attributes.file_id#.cf_meta_select_#listlast(cf_id,'-')#.value = document.form#attributes.file_id#.cf_select_#listlast(cf_id,'-')#.value;" </cfif> style="width:300px;"<cfif !allowed> disabled="disabled"</cfif>>
							<option value=""></option>
							<cfloop list="#ltrim(ListSort(replace(cf_select_list,', ',',','ALL'), 'text', 'asc', ','))#" index="i">
								<option value="#i#"<cfif i EQ "#cf_value#"> selected="selected"</cfif>>#i#</option>
							</cfloop>
						</select>
					</cfif>
				</td>
			</tr>
		</cfloop>
	<cfif !structKeyExists(variables,"cf_inline")></table></cfif>
</cfoutput>