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
			<th>#defaultsObj.trans("header_backup_restore")#</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("header_backup_restore_desc")#</td>
		</tr>
		<tr>
			<td style="background-color:yellow;font-weight:bold;">During a Backup or Restore operation your server will become unresponsive to any requests! Do these operation when no one is accessing your server.</td>
		</tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th>Backup</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("admin_maintenance_backup_desc2")#<br /><br />
			Backup to: <input type="radio" name="tofiletype" id="tofiletype" value="raz" checked="checked"> Razuna format &mdash; Export to:<input type="radio" name="tofiletype" id="tofiletype" value="sql"> SQL file <input type="radio" name="tofiletype" id="tofiletype" value="xml"> XML file <input type="button" name="backup" value="Backup" class="button" onclick="dobackup();" style="margin-left:30px;"><div id="backup_progress"></div><div id="backup_dummy"></div></td>
		</tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="3">#defaultsObj.trans("admin_maintenance_restore_desc")#</th>
		</tr>
		<tr>
			<td colspan="3">#defaultsObj.trans("admin_maintenance_restore_desc2")#</td>
		</tr>
		<tr>
			<td><strong>Backup Date</strong></td>
			<td><strong>Restore</strong></td>
			<td><strong>Remove</strong></td>
		</tr>
		<cfloop query="qry_backup">
			<tr>
				<td>#dateformat(back_date,"mmmm dd yyyy")#, #timeformat(back_date,"HH:mm:ss")#</td>
				<td><a href="##" onclick="dorestore('#back_id#');">Restore</a></td>
				<td><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=prefs_backup&id=#back_id#&loaddiv=backrest','#defaultsObj.trans("remove_selected")#',400,1);return false">Remove</a></td>
			</tr>
		</cfloop>
		<tr>
			<td colspan="3"><a href="##" onclick="loadcontent('backrest','#myself#c.prefs_backup_restore');">Refresh</a></td>
		</tr>
	</table>
	<div id="dummy_maintenance"></div>
	<!--- Load Progress --->
	<script language="JavaScript" type="text/javascript">
		// Do Backup
		function dobackup(){
			// Clear the value of the divs
			// $("##backup_progress").html('');
			// $("##backup_dummy").html('');
			// Get value of server or download
			// var backuptosystem = $('##backuptosystem').val();
			var tofiletype = $('input:radio[name=tofiletype]:checked').val();
			// Set div to waiting
			// $("##backup_progress").html('Working...Please wait!');
			// loadinggif('backup_dummy');
			// Start backup
			// loadcontent('backup_dummy','#myself#c.prefs_backup_do&backuptosystem=' + backuptosystem);
			window.open('#myself#c.prefs_backup_do&tofiletype=' + tofiletype, 'winbackup', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=500,height=500');
		}
		// Do Restore from filesystem
		function dorestore(backid){
			// Clear the value of the divs
			// $("##restore_progress").html('');
			// $("##restore_dummy").html('');
			// Get the selected file
			// var thebackupfile = $('##thebackupfile').val();
			// if (thebackupfile == null){
				// Alert user
			//	$("##restore_progress").html('<span style="color:red;">Please select a backup file!</span>');
			// }
			// else {
				// Set div to waiting
				// $("##restore_progress").html('Working...Please wait!');
				// loadinggif('restore_dummy');
				// Get value of reindex
				// var reindex = $('##reindex').attr('checked');
				// Start Restore
				//loadcontent('restore_dummy','#myself#c.prefs_restore_do&thebackupfile=' + escape(thebackupfile));
				// window.open('#myself#c.prefs_restore_do&thebackupfile=' + escape(thebackupfile));
				window.open('#myself#c.prefs_restore_do&back_id=' + escape(backid), 'winrestore', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=500,height=500');
			//}
		}
	</script>
</cfoutput>
