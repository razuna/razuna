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

	<!--- <cfdump var="#qry_files.files#"><cfabort>  --->

	<div id="done_message"></div>

	<!--- Only if allowed --->
	<cfif qry_enabled.approval_enabled AND session.is_system_admin OR session.is_administrator OR listFind(qry_users.user_ids, session.theuserid)>

		<!--- If nothing here --->
		<cfif qry_files.files.recordcount EQ 0>
			<h3>Nothing here (anymore) to approve!</h3>
		</cfif>

		<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">

		<cfloop query="qry_files.files">
			<!--- Set vars --->
			<cfif kind EQ "img">
				<cfset _kind = "images">
				<cfset _detail_link = "c.images_detail">
			<cfelseif kind EQ "vid">
				<cfset _kind = "videos">
				<cfset _detail_link = "c.videos_detail">
			<cfelseif kind EQ "aud">
				<cfset _kind = "audios">
				<cfset _detail_link = "c.audios_detail">
			<cfelse>
				<cfset _kind = "files">
				<cfset _detail_link = "c.files_detail">
			</cfif>
			<!--- Show files --->
			<div id="approval_#id#" class="approval_class">
				<!--- Thumbnail --->
				<div style="float:left;padding-right:25px;">
					<a href="##" onclick="showwindow('#myself#?fa=#_detail_link#&file_id=#id#&what=#_kind#&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=false','',1000,1);return false;">
						<cfif application.razuna.storage EQ "amazon">
							<cfif cloud_url NEQ "">
								<img src="#cloud_url#" border="0" style="max-width:110px;max-height:110px;">
							<cfelse>
								<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0" style="max-width:110px;max-height:110px;">
							</cfif>
						<cfelse>
							<cfif kind EQ "img">
								<img src="#thestorage##path_to_asset#/thumb_#id#.#thumb_extension#?_v=#hashtag#" border="0" style="max-width:110px;max-height:110px;">
							<cfelseif kind EQ "vid">
								<cfset thethumb = replacenocase(filename_org, ".#extension#", ".jpg", "all")>
								<img src="#thestorage##path_to_asset#/#thethumb#?_v=#hashtag#" border="0" style="max-width:110px;max-height:110px;">
							<cfelseif kind EQ "aud">
								<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif extension EQ "mp3" OR extension EQ "wav">#extension#<cfelse>aud</cfif>.png" border="0">
							<cfelse>
								<cfset thethumb = replacenocase(filename_org, ".#extension#", ".jpg", "all")>
								<cfif FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") >
									<img src="#thestorage##path_to_asset#/#thethumb#?_v=#hashtag#" border="0" style="max-width:110px;max-height:110px;">
								<cfelse>
									<img src="#dynpath#/global/host/dam/images/icons/icon_#extension#.png" border="0" width="128" height="128" onerror = "this.src='#dynpath#/global/host/dam/images/icons/icon_txt.png'">
								</cfif>
							</cfif>
						</cfif>
					</a>
				</div>
				<!--- Right side --->
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
						<a href="##" onclick="showwindow('#myself#?fa=#_detail_link#&file_id=#id#&what=#_kind#&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=false','',1000,1);return false;">Check details</a>
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
						<button class="awesome big green" onclick="approve_file('#id#', '#kind#')">Approve</button>
						<button class="awesome big red" onclick="showwindow('#myself##xfa.reject#&file_id=#id#&file_type=#kind#&file_owner=#file_owner#','',600,1);return false;">Reject</button>
					</cfif>
				</div>
				<div class="clear" style="padding-bottom:10px;"></div>
				<hr>
			</div>
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
					$('##approval_' + id).hide('slide', {direction: 'right'}, 500, function() {
						checkDivs();
					});
				})
				.fail( function() {
					alert('fail!!!!!!!')
				});
			}
			// Check how many divs are there
			function checkDivs() {
				// Get divs
				var _divs = $('.approval_class').not( ':hidden' ).length;
				// If length is zero display message
				if ( !_divs ) {
					$('##done_message').html('<h2 style="color:green;">Yayay! You approved all file(s). Now go take a break.</h2>');
				}
			}
		</script>

	<!--- Not allowed --->
	<cfelse>
		<h1>No access here</h1>

	</cfif>

</cfoutput>