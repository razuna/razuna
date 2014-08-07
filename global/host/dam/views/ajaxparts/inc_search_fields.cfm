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
		<td><input type="hidden" name="thetype" value="#myvar.thetype#">
			<input type="text" name="searchfor" id="searchforadv_#myvar.thetype#" style="width:300px;" class="textbold"></td>
	</tr>
	<!--- If the search selection is on we search with folder ids --->
	<cfif cs.search_selection AND attributes.folder_id EQ 0>
		<td></td>
		<td>
			<!--- This is the selected value (should come from the defined selection of the user) --->
			<select data-placeholder="" class="chzn-select" name="adv_folder_id" id="adv_folder_id" style="min-width:150px;">
				<!--- <option value="0">Search in all</option> --->
				<cfloop query="qry_searchselection">
					<option value="#folder_id#"<cfif session.user_search_selection EQ "#folder_id#"> selected="selected"</cfif>>#folder_name#</option>
				</cfloop>
			</select>
		</td>
	</cfif>
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
		<td valign="top">#myFusebox.getApplicationData().defaults.trans("labels")#</td>
		<td>
			<!--- Check the labels record count is less than 200 --->
			<cfif attributes.thelabelsqry.recordcount LTE 200>
				<select data-placeholder="Choose a label" class="chzn-select" style="width:311px;" name="labels" id="search_labels_#myvar.thetype#" multiple="multiple">
					<option value=""></option>
					<cfloop query="attributes.thelabelsqry">
						<cfset l = replace(label_path," "," ","all")>
						<cfset l = replace(l,"/"," ","all")>
						<option value="#l#">#label_path#</option>
					</cfloop>
				</select>
			<cfelse>
				<!--- For RAZ - 2708 Label text area --->
				<div style="width:450px;">
					<div id="lables_#myvar.thetype#" class="labelContainer"  style="float:left;width:311px;" >
						<cfloop query="attributes.thelabelsqry">
							<cfif ListFind(evaluate("session.search.labels_#myvar.thetype#"),'#label_id#') NEQ 0>
							<div class='singleLabel'  id="#label_id#">
								<span>#label_path#</span>
								<a class='labelRemove'  onclick="removeLabel('0','#myvar.thetype#', '#label_id#',this)" >X</a>
							</div>
							</cfif>
						</cfloop>
					</div>
					<!--- Select label button --->
					<a style = "float:left;clear:both;" onclick="showwindow('#myself#c.select_label_popup&file_id=0&file_type=#myvar.thetype#&closewin=2','Choose Labels',600,2);return false;" href="##"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("select_labels")#</button></a>
				</div>
				<!--- To pass the label text values --->
				<input type="hidden" name="labels" id="search_labels_#myvar.thetype#" value="">
			</cfif>
			
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
		<cfif myvar.thetype EQ qry_fields.cf_show OR qry_fields.cf_show EQ 'all' OR myvar.thetype EQ 'all' AND qry_fields.cf_show NEQ 'users'>
			<tr>
				<td nowrap="true">#cf_text#</td>
				<td>
					<cfset cfid = replace(cf_id,"-","","all")>
					<!--- For text --->
					<cfif cf_type EQ "text" OR cf_type EQ "textarea">
						<input type="text" style="width:300px;" name="cf#cfid#" >
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