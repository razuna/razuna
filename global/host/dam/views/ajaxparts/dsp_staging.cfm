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
	<h2>Approval Area</h2>

	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">

	<cfloop query="qry_files.files">
		<cfif kind EQ "img">
			<div id="approval_#id#">
				<div style="float:left;padding-right:25px;">
					<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=false','',1000,1);return false;">
						<cfif application.razuna.storage EQ "amazon">
							<cfif cloud_url NEQ "">
								<img src="#cloud_url#" border="0">
							<cfelse>
								<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
							</cfif>
						<cfelse>
							<img src="#thestorage##path_to_asset#/thumb_#id#.#thumb_extension#?#hashtag#" border="0">
						</cfif>
					</a>
				</div>
				<div>
					<h3>#name#</h3>
					<p>
						Added on: #dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
					</p>
					<p>
						By user: #user_first_name# #user_last_name#
					</p>
					<p>
						Folder: #folder_name#
					</p>
					<br>
					<p>
						<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=false','',1000,1);return false;">Check details</a>
					</p>
					<br>
					<br>
					<cfquery dbtype="query" name="_approved">
					SELECT approval_date
					FROM qry_files.done
					WHERE user_id = '#session.theuserid#'
					AND file_id = '#id#'
					</cfquery>
					<cfif _approved.recordcount NEQ 0>
						<strong>You already approved this file on #dateformat(_approved.approval_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(_approved.approval_date, "HH:mm")#. Looks like we are waiting on others to approve, too.</strong>
					<cfelse>
						<button class="awesome big green" onclick="approve_file('#id#', 'img')">Approve</button>
						<button class="awesome big red">Reject</button>
					</cfif>
				</div>
				<div class="clear" style="padding-bottom:10px;"></div>
				<hr>
			</div>
		</cfif>
	</cfloop>

	<script type="text/javascript">
		function approve_file(id, type) {
			// Submit for further approval check
			$.ajax({
				type: "POST",
				url: '#myself#c.approval_accept',
				data: { 'file_id' : id, 'file_type' : type }
			})
			.done( function() {
				$('##approval_' + id).hide('slide', {direction: 'right'}, 500);
			})
			.fail( function() {
				alert('fail!!!!!!!')
			});
		}
	</script>
</cfoutput>