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
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="2">#defaultsObj.trans("admin_maintenance_restore_desc")#</th>
		</tr>
		<tr>
			<td colspan="2" style="background-color:yellow;font-weight:bold;padding:10px;">Once you start restoring it may appear as your browsing comes to a halt. Restoring can take some time, so please be patient and wait!</td>
		</tr>
		<tr>
			<td colspan="2"><strong>#defaultsObj.trans("admin_maintenance_restore_file")#</strong><br />
			#defaultsObj.trans("admin_maintenance_restore_file_desc")#</td>
		</tr>
		<tr>
			<td><strong>Backup Date</strong></td>
			<td><strong>Restore</strong></td>
		</tr>
		<cfloop query="qry_backup">
			<tr>
				<td>#dateformat(back_date,"mmmm dd yyyy")#, #timeformat(back_date,"HH:mm:ss")#</td>
				<td><a href="##" onclick="dorestore('#back_id#');">Restore</a></td>
			</tr>
		</cfloop>
		<tr>
			<td colspan="2" style="padding:10px;">After a successful restore you can <a href="#self#?fusebox.loadclean=true&fusebox.password=razfbreload&fusebox.parseall=true&v=#createuuid()#">click here to get to Razuna</a>.</td>
		</tr>
	</table>
	<div>
		<div style="float:left;padding:20px 0px 0px 0px;">
			<input type="button" id="next" value="#defaultsObj.trans("back")#" onclick="loadcontent('load_steps','#myself#c.first_time_database_config&db=#session.firsttime.database#');" class="button">
		</div>
	</div>
	<div id="dummy_maintenance"></div>
	<!--- Load Progress --->
	<script language="JavaScript" type="text/javascript">
		// Do Restore from filesystem
		function dorestore(backid){
			// Clear the value of the divs
			$("##restore_progress").html('');
			// $("##restore_dummy").html('');
			// Get the selected file
			// var thebackupfile = $('##thebackupfile').val();
			// if (thebackupfile == null){
				// Alert user
			// 	$("##restore_progress").html('<span style="color:red;">Please select a backup file!</span>');
			// }
			// else {
				// Set div to waiting
				// $("##restore_progress").html('Working...Please wait!');
				// loadinggif('restore_dummy');
				// Get value of reindex
				// var reindex = $('##reindex').attr('checked');
				// Start Restore
				// loadcontent('restore_dummy','#myself#c.first_time_database_restore_system&thebackupfile=' + backid);
				window.open('#myself#c.first_time_database_restore_system&back_id=' + backid, 'winrestore', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=500,height=500');
			//}
		}
	</script>
</cfoutput>
