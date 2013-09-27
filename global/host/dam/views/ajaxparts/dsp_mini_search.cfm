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
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	We've found <cfif #qry_filecount.thetotal# EQ "">0<cfelse>#qry_filecount.thetotal#</cfif> file(s).
	<br /><br />
		<cfloop query="qry_files.qall">
			<div id="files">
				<div id="filesthumbs">
					<a href="##" onclick="slidefilesearch('#id#','#kind#');return false;">
						<cfif kind EQ "img">
							<!--- Show assets --->
							<cfif link_kind NEQ "url">
								<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
									<cfif cloud_url NEQ "">
										<img src="#cloud_url#" border="0">
									<cfelse>
										<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
									</cfif>
								<cfelse>
									<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#?#hashtag#" border="0">
								</cfif>
							<cfelse>
								<img src="#link_path_url#" border="0" width="120">
							</cfif>
						<cfelseif kind EQ "vid">
							<cfif link_kind NEQ "url">
								<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
									<cfif cloud_url NEQ "">
										<img src="#cloud_url#" border="0">
									<cfelse>
										<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
									</cfif>
								<cfelse>
									<img src="#thestorage##path_to_asset#/#filename_org#?#hashtag#" border="0">
								</cfif>
							<cfelse>
								<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
							</cfif>
						<cfelseif kind EQ "aud">
							<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0">
						<cfelse>
							<!--- If it is a PDF we show the thumbnail --->
							<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND ext EQ "PDF">
								<cfif cloud_url NEQ "">
									<img src="#cloud_url#" border="0">
								<cfelse>
									<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
								</cfif>
							<cfelseif application.razuna.storage EQ "local" AND ext EQ "PDF">
								<cfset thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")>
								<cfif !FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#")>
									<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0">
								<cfelse>
									<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/#thethumb#" width="120" border="0">
								</cfif>
							<cfelse>
								<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png")>
									<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="120" height="120" border="0">
								</cfif>
							</cfif>
						</cfif>
					</a>
				</div>
				<div id="foldername_list"><a href="##" onclick="slidefilesearch('#id#','#kind#');return false;">#filename#</a></div>
				<div style="clear:both;"></div>
				<!--- This div loads dynamically --->
				<div id="slidersearch#id#" style="display:none;">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
			</div>
		</cfloop>
	</div>
	<!--- JS --->
	<script type="text/javascript">
		// Slide file
		function slidefilesearch(theid,thekind){
			$('##slidersearch' + theid).load('#myself#c.mini_browser_files&file_id=' + theid + '&kind=' + thekind, function(){
				$('##slidersearch' + theid).slideToggle('slow');
			})
		}
	</script>
</cfoutput>