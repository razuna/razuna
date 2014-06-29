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
	<div id="updatertabs">
		<ul>
			<li><a href="##logs">Log</a></li>
			<li><a href="##download">Download Application</a></li>
			<li><a href="##faq">FAQ / Help</a></li>
		</ul>
		<!--- Log --->
		<div id="logs">
			<!--- If empty --->
			<cfif qry_logs.recordcount EQ 0>
				<h1>No log entries</h1>
				<h2>Come back here when you started uploading files to see the progress</h2>
			<cfelse>
				<div style="float:left;"><a href="##" onclick="loadcontent('rightside','#myself#c.updater_tool');return false;"><strong>Refresh</strong></a></div>
				<div style="float:right;"><a href="##" onclick="loadcontent('rightside','#myself#c.updater_tool_clean_log');return false;"><strong>Delete log entries</strong></a></div>
				<div style="clear:both;padding-top:15px;"></div>
				<table border="0" width="100%" cellspacing="0" cellpadding="0" class="tablepanel">
					<thead>
						<tr>
							<th>Date</th>
							<th>Who</th>
							<th>Filename</th>
							<th>Status</th>
						</tr>
					</thead>
					<tbody>
						<cfloop query="qry_logs">
							<tr style="background-color:<cfif currentrow mod 2>##f5f5f5;<cfelse>white;</cfif>">
								<td nowrap="nowrap">#dateformat(date_upload, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeFormat(date_upload, 'HH:mm:ss')#</td>
								<td nowrap="nowrap">#user_first_name# #user_last_name#</td>
								<td nowrap="nowrap">#file_name#</td>
								<cfif file_status EQ "success">
									<td><img src="#dynpath#/global/host/dam/images/dialog-ok-apply-4.png" border="0"></td>
								<cfelse>
									<td style="color:red;" nowrap="nowrap">File could not be matched</td>
								</cfif>
							</tr>
						</cfloop>
					</tbody>
				</table>
			</cfif>
		</div>
		<!--- download --->
		<div id="download">
			<h2>Download application to restore files</h2>
			<p>Here you can download a desktop application for Windows or MacOS X. This tool has been designed so you can upload your missing files back into Razuna.</p>
			<p>
				<a href="http://s.razuna.com.s3.amazonaws.com/installers/uploader/restore/Razuna-Uploader.zip">Download for MacOS X</a>
			</p>
			<p>
				<a href="http://s.razuna.com.s3.amazonaws.com/installers/uploader/restore/RazunaUploader-installer.exe">Download for Windows</a>
			</p>
			<p>
				Please refer to our <a href="##" onclick="$('##updatertabs').tabs({ active: 2 }).tabs( 'refresh' );">help section</a> on how to use the application.
			</p>
		</div>
		<!--- faq --->
		<div id="faq">
			<table border="0" width="100%" cellspacing="0" cellpadding="0" class="tablepanel">
				<tr>
					<!--- FAQ --->
					<td width="70%" valign="top">
						<h3>FAQ on your files</h3>
						<h4>What happened?</h4>
						<p>
							This past Thursday we had a major hardware failure that affected not only our main storage server, but our backup storage as well. 
						</p>
						<p>
							We use RAID 6 servers, so a failing harddisk is normally no problem. In our case, four disks failed at the same time, which means we can no longer run a repair to get the files back.
						</p>
						<h4>Don't you have a backup?</h4>
						<p>
							Yes, we have a mirrored RAID 6 backup server, which had exactly the same failure at the same time. We use a mirror, so that if the main server fails, we can immediately point to the other and customers will then normally not see any downtime.
						</p>
						<p>
							Unfortunately, we were hit with a failure of the main storage and the backup server at the same time.
						</p>
						<h4>What happens to our data?</h4>
						<p>
							What's been affected is the files. The data such as users, folders, groups, meta-data, labels, keywords etc. has been successfully restored. The defective disks have been couriered to a leading data recovery company. They are now analysing them and will then try to restore the files. 
						</p>
						<h4>Will I lose my files?</h4>
						<p>
							The honest answer is that we don't know. This is unmapped territory, as a four-disk failure in a RAID 6 system is very rare.
						</p>
						<p>
							If you have files that were uploaded to Razuna on your harddisk or other servers, we suggest you upload them via the emergency upload tool. Razuna will then map it against its records, and if you are re-uploading a file, all the metadata will be restored and the file will automatically be moved to the right folders and collections with the same asset-ID and permission levels.
						</p>
						<h4>When will you know, what can be recovered?</h4>
						<p>
							An analysis and diagnose typically can take from one day to many days. As we need to have 39TB analysed, it will probably take a few days. Once we have the result of the analysis, we will inform you about the next steps.
						</p>
						<h4>Will Razuna work normally going forward?</h4>
						<p>
							Yes. The Razuna service itself was never affected as it was not a software error. The Razuna service is now fully restored, including uploading files, will be handled as normal going forward.
						</p>
						<h4>What have you done to prevent this from happening again?</h4>
						<p>
							Well, theoretically it wasn't supposed to happen to begin with. We are absolutely shocked. In order to prevent something like this from happening again, we have implemented a double backup. I don't think there are a lot of companies with double backups, but that's what we've done.
						</p>
						<p>
							For performance reasons, we are still using a mirror with RAID 6, so a similar breakdown in one server, would not be noticeable. If two servers break down, we have a cloud backup via Amazon S3. So a similar, but still theoretically close to impossible, failure would mean that we would have down-time but that files would be recoverable.
						</p>
					</td>
					<!--- App help link --->
					<td width="30%" valign="top">
						<h3>Application Help</h3>
						<p>
							<a href="http://wiki.razuna.com/display/ecp/The+Desktop+File+Restorer" target='_blank'>Detailed help on how install, set-up and use the application</a>
						</p>
					</td>
				</tr>
		</div>
	</div>
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		// Activate Chosen
		$(".chzn-select").chosen({search_contains: true});
		jqtabs("updatertabs");
	</script>	
</cfoutput>
	
