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
			<tr>
				<cfif !structKeyExists(variables,"cf_inline")>
					<td width="130" nowrap="true"<cfif cf_type EQ "textarea"> valign="top"</cfif>><strong>#cf_text#</strong></td>
					<td width="320">
				<cfelse>
					<td>
				</cfif>
					<!--- For text --->
					<cfif cf_type EQ "text">
						<input type="text" style="width:300px;" id="cf_#cf_id#" name="cf_#cf_id#" value="#cf_value#"<cfif structKeyExists(variables,"cf_inline")> placeholder="#cf_text#"</cfif><cfif cf_edit NEQ "true" AND (NOT listfind(cf_edit,session.theuserid) AND NOT listfind(cf_edit,session.thegroupofuser))> disabled="disabled"</cfif>>
					<!--- Radio --->
					<cfelseif cf_type EQ "radio">
						<input type="radio" name="cf_#cf_id#" value="T"<cfif cf_value EQ "T"> checked="true"</cfif><cfif cf_edit NEQ "true" AND (NOT listfind(cf_edit,session.theuserid) AND NOT listfind(cf_edit,session.thegroupofuser))> disabled="disabled"</cfif>>#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="cf_#cf_id#" value="F"<cfif cf_value EQ "F" OR cf_value EQ ""> checked="true"</cfif><cfif cf_edit NEQ "true" AND (NOT listfind(cf_edit,session.theuserid) AND NOT listfind(cf_edit,session.thegroupofuser))> disabled="disabled"</cfif>>#myFusebox.getApplicationData().defaults.trans("no")#
					<!--- Textarea --->
					<cfelseif cf_type EQ "textarea">
						<textarea name="cf_#cf_id#" style="width:310px;height:60px;"<cfif structKeyExists(variables,"cf_inline")> placeholder="#cf_text#"</cfif><cfif cf_edit NEQ "true" AND (NOT listfind(cf_edit,session.theuserid) AND NOT listfind(cf_edit,session.thegroupofuser))> disabled="disabled"</cfif>>#cf_value#</textarea>
					<!--- Select --->
					<cfelseif cf_type EQ "select">
						<select name="cf_#cf_id#" style="width:300px;"<cfif cf_edit NEQ "true" AND (NOT listfind(cf_edit,session.theuserid,",") AND NOT listfind(cf_edit,session.thegroupofuser,","))> disabled="disabled"</cfif>>
							<option value=""></option>
							<cfloop list="#ListSort(cf_select_list, 'text', 'asc', ',')#" index="i">
								<option value="#i#"<cfif i EQ "#cf_value#"> selected="selected"</cfif>>#i#</option>
							</cfloop>
						</select>
					</cfif>
				</td>
			</tr>
		</cfloop>
	<cfif !structKeyExists(variables,"cf_inline")></table></cfif>
</cfoutput>