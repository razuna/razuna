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
	<tr>
		<td>Search Term</td>
		<td><input type="text" name="searchfor" id="searchforadv_#myvar.thetype#" style="width:300px;" class="textbold"></td>
	</tr>
	<tr>
		<td>Filename</td>
		<td><input type="text" name="filename" style="width:300px;" class="textbold"></td>
	</tr>
	<tr>
		<td>Keywords</td>
		<td><input type="text" name="keywords" style="width:300px;" class="textbold"></td>
	</tr>
	<tr>
		<td>Description</td>
		<td><input type="text" name="description" style="width:300px;" class="textbold"></td>
	</tr>
	<tr>
		<td>#myFusebox.getApplicationData().defaults.trans("labels")#</td>
		<td>
			<select data-placeholder="Choose a label" class="chzn-select" style="width:311px;" name="labels" id="search_labels_#myvar.thetype#" multiple="multiple">
				<option value=""></option>
				<cfloop query="attributes.thelabelsqry">
					<cfset l = replace(label_path," "," ","all")>
					<cfset l = replace(l,"/"," ","all")>
					<option value="#l#">#label_path#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td>Extension</td>
		<td><input type="text" name="extension" style="width:300px;" class="textbold"></td>
	</tr>
	<tr>
		<td nowrap="true">All Metadata</td>
		<td><input type="text" name="rawmetadata" style="width:300px;" class="textbold"></td>
	</tr>
	<cfloop query="qry_fields">
		<cfif myvar.thetype EQ qry_fields.cf_show OR myvar.thetype EQ 'all' AND qry_fields.cf_show NEQ 'users'>
			<tr>
				<td nowrap="true">#cf_text#</td>
				<td>
					<cfset cfid = replace(cf_id,"-","","all")>
					<!--- For text --->
					<cfif cf_type EQ "text" OR cf_type EQ "textarea">
						<input type="text" style="width:300px;" name="cf#cfid#">
					<!--- Radio --->
					<cfelseif cf_type EQ "radio">
						<input type="radio" name="cf#cfid#" value="T">#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="cf#cfid#" value="F">#myFusebox.getApplicationData().defaults.trans("no")#
					<!--- Select --->
					<cfelseif cf_type EQ "select">
						<select name="cf#cfid#" style="width:300px;">
							<option value="" selected="selected"></option>
							<cfloop list="#ListSort(cf_select_list, 'text', 'asc', ',')#" index="i">
								<option value="#i#">#i#</option>
							</cfloop>
						</select>
					</cfif>
				</td>
			</tr>
		</cfif>
	</cfloop>
</cfoutput>