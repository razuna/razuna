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
	<cfif session.hosttype EQ 0>
		Here you can rebuild your search index, backup and restore your database and more.<br><br>
		<cfinclude template="dsp_host_upgrade.cfm">
	<cfelse>
		<!--- Re-Index --->
		<!--- <table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<th>#myFusebox.getApplicationData().defaults.trans("admin_maintenance_searchsync")#</th>
			</tr>
			<tr class="list">
				<td>
					#myFusebox.getApplicationData().defaults.trans("admin_maintenance_desc")#
					<br /><br />
					<div style="padding:10px;background-color:##FFFFE0;color:##900;" class="box">During a rebuild of the search index the server might become unresponsive to any requests. Do a rebuild when no one is accessing your server!</div>
					<br />
					<input type="button" name="doreindex" value="#myFusebox.getApplicationData().defaults.trans("admin_maintenance_do")#" onclick="doreindexassets();" class="button" />
					<br /><br />
				</td>
			</tr>
		</table> --->
		<!--- Database Cache --->
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<th>#myFusebox.getApplicationData().defaults.trans("admin_maintenance_flushdb_header")#</th>
			</tr>
			<tr class="list">
				<td>
				#myFusebox.getApplicationData().defaults.trans("admin_maintenance_flushdb_desc")#<br /><br />
				<!---
Please choose the database cache to flush:<br />
				<input type="checkbox" name="images" id="dbf_img" value="images" /> Images <input type="checkbox" name="videos" id="dbf_vid" value="videos" /> Videos <input type="checkbox" name="audios" id="dbf_aud" value="audios" /> Audios <input type="checkbox" name="files"  id="dbf_doc" value="files" /> Documents <input type="checkbox" name="folders" id="dbf_fol" value="folders" /> Folders <input type="checkbox" name="users" id="dbf_users" value="users" /> Users <input type="checkbox" name="logs" id="dbf_logs" value="logs" /> Logs <br />
--->
				<input type="button" name="flushdb" value="#myFusebox.getApplicationData().defaults.trans("admin_maintenance_flushdb_link")#" onclick="dodbflush();" class="button" />
				<br /><br />
				<div id="flush_db_feedback" style="display_none;"></div>
				</td>
			</tr>
		</table>
		<cfif !application.razuna.isp>
			<!--- Clear Cache --->
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<tr>
					<th>#myFusebox.getApplicationData().defaults.trans("admin_maintenance_flushtemplate_header")#</th>
				</tr>
				<tr class="list">
					<td>
					#myFusebox.getApplicationData().defaults.trans("admin_maintenance_flushtemplate_desc")#<br /><br />
					<a href="#session.thehttp##cgi.http_host##cgi.script_name#?fusebox.loadclean=true&fusebox.password=razfbreload&fusebox.parseall=true&_v=#createuuid('')#" target="_blank" style="text-decoration:none;">
					<input type="button" name="rebuiltcache" value="#myFusebox.getApplicationData().defaults.trans("admin_maintenance_flushtemplate_link")#" class="button" /></a>
					<br /><br />
					</td>
				</tr>
			</table>
		</cfif>
		<!--- Database Cleaner --->
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<th>#myFusebox.getApplicationData().defaults.trans("admin_maintenance_db_cleaner")#</th>
			</tr>
			<tr>
				<td>
				#myFusebox.getApplicationData().defaults.trans("admin_maintenance_db_cleaner_desc")#<br /><br />
				<input type="button" name="cleaner" value="#myFusebox.getApplicationData().defaults.trans("admin_maintenance_db_cleaner_link")#" onclick="docleaner();" class="button" />
				<br /><br />
				</td>
			</tr>
		</table>
		<!--- Backup --->
		<!--- <table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<th>#myFusebox.getApplicationData().defaults.trans("admin_maintenance_backup_desc")#</th>
			</tr>
			<tr class="list">
				<td>#myFusebox.getApplicationData().defaults.trans("admin_maintenance_backup_desc2")#<br /><br />
				Save to: <input type="radio" name="tofiletype" id="tofiletype" value="sql" checked="checked"> SQL file <input type="radio" name="tofiletype" id="tofiletype" value="xml"> XML file <input type="button" name="backup" value="Export Now" class="button" onclick="dobackup();" style="margin-left:30px;"><div id="backup_progress"></div><div id="backup_dummy"></div></td>
			</tr>
		</table> --->
		
		<div id="dummy_maintenance"></div>
		<!--- Load Progress --->
		<script type="text/javascript">
			// Do flush db cache
			function dodbflush(){
				/*
var img = $('##dbf_img:checked').val();
				var vid = $('##dbf_vid:checked').val();
				var aud = $('##dbf_aud:checked').val();
				var doc = $('##dbf_doc:checked').val();
				var fol = $('##dbf_fol:checked').val();
				var use = $('##dbf_users:checked').val();
				var log = $('##dbf_logs:checked').val();
*/
				// Load action
				loadcontent('dummy_maintenance','#myself#c.admin_flush_db');
				// Load in status
				$('##flush_db_feedback').css('display','');
				$('##flush_db_feedback').html('<span style="color:green;font-weight:bold;">Database caches have been flushed!</span>');
			}
			// Do Re-Index
			function doreindexassets(){
				window.open('#myself#c.admin_rebuild_do&v=#createuuid()#', 'winreindex', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=500,height=500');
			};
			// Do Backup
			function dobackup(){
				var tofiletype = $('input:radio[name=tofiletype]:checked').val();
				window.open('#myself#c.admin_backup&tofiletype=' + tofiletype, 'winbackup', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=500,height=500');
			};
			// Do Cleaner
			function docleaner(){
				window.open('#myself#c.admin_cleaner&v=#createuuid()#', 'wincleaner', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=800,height=600');
			};
			// Do Restore from filesystem
			function dorestore(backid){
				// Clear the value of the divs
				$("##restore_progress").html('');
				window.open('#myself#c.admin_restore&back_id=' + escape(backid), 'winrestore', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=500,height=500');
			};
		</script>
	</cfif>
</cfoutput>