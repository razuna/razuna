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

	<h2>Approval</h2>
	<p>Configure your approval process below. Once the approval process is activated, it will execute *before* any workflow, i.e. if you have a workflow applied to a folder all workflow actions will execute *after* after the files have been aproved.</p>
	
	<hr>

	<!--- Activate --->
	<h3>Enable approval process</h3>
	<p>Check the checkbox below in order to have the approval process enabled. Once activated it will apply imemdiately to all (selected) folders.</p>
	<p>
		<input type="checkbox" value="true" name="approval_active"> Enable approval process
	</p>

	<!--- Folder selection --->
	<h3>Folder Selection</h3>
	<p>Select the folders that the approval process should apply to.</p>
	<table width="100%" border="0">
		<tr>
			<td style="width:450px;">Folder selection over here</td>
			<td valign="top"><input type="checkbox" value="all" name="folder_selection"> Apply approval process to all folders</td>
		</tr>
	</table>
	
	<!--- Approval Group 1 --->
	<h3>Approval Group 1</h3>
	<p>Select from the list which users/groups are responsible to approve uploads</p>
	<!--- <cfdump var="#qry_groups#"><cfabort>  --->
	<table width="100%" border="0">
		<tr>
			<td style="width:450px;">
				<select data-placeholder="Choose users/groups" class="chzn-select" style="width:450px;" tabindex="2" id="selectuser" multiple>
					<option value=""></option>
					<optgroup label="Groups">
						<cfloop query="qry_groups">
							<option value="#grp_id#">#grp_name#</option>
						</cfloop>
					</optgroup>
					<optgroup label="Users">
						<cfoutput query="qry_users" group="user_id">
							<option value="#user_id#">#user_first_name# #user_last_name# (#user_email#)</option>
						</cfoutput>
					</optgroup>
				</select>
			</td>
			<td valign="top">
				<input type="checkbox" value="true" name="approval_group_1_all"> All users/groups have to approve
			</td>
		</tr>
	</table>
</cfoutput>
<!--- JS --->
<script type="text/javascript">
	// Activate Chosen
	$(".chzn-select").chosen({search_contains: true, single_backstroke_delete : false });
</script>

