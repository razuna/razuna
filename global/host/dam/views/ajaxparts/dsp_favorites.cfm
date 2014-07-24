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
<!--- Storage Decision --->
<!---
<cfif application.razuna.storage EQ "nirvanix">
	<cfset thestorage = "#application.razuna.nvxurlservices#/#attributes.nvxsession#/razuna/#session.hostid#/">
<cfelse>
--->
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<cfset uniqueid = createuuid()>
<!--- </cfif> --->
<cfoutput>
	<cfif qry_favorites.recordcount EQ 0>
		<div style="text-align:center;width:100%;color:grey;"><h2>Drag asset here to add to your favorites</h2></div>
	<cfelse>
		<div style="padding-top:5px;">
			<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites');">Refresh</a>
		</div>
		<div style="overflow:auto;font-weight:normal;">
		<table border="0">
			<tr>
			<cfloop query="qry_favorites">
				<cfset myid = #cart_product_id#>
				<td width="90">
					<cfif fav_type EQ "folder">
						<a href="##" onclick="loadcontent('rightside','#myself##xfa.folder#&folder_id=#myid#');return false;" style="text-decoration:none;">
							<img src="#dynpath#/global/host/dam/images/folder-brown.png" border="0" style="pading:0;margin:0;"><br>#mid(thename,1,28)#<cfif len(thename) GT 28>...</cfif>
						</a>		
					<cfelse>
						<cfif fav_kind EQ "img">
							<a href="##" onclick="showwindow('#myself##xfa.imagedetail#&file_id=#myid#&what=images&loaddiv=&folder_id=0','#thename#',1000,1);return false;">
								<cfloop query="qry_theimage">
									<cfif myid EQ img_id>
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#thestorage##path_to_asset#/thumb_#img_id#.#thumb_extension#" border="0">
											</cfif>
										<cfelse>
											<img src="#link_path_url#" border="0">
										</cfif>
									</cfif>
								</cfloop>	
							</a>
						<cfelseif fav_kind EQ "vid">
							<a href="##" onclick="showwindow('#myself##xfa.videodetail#&file_id=#myid#&what=videos&loaddiv=&folder_id=0','#thename#',1000,1);return false;">
								<cfloop query="qry_thevideo">
									<cfif myid EQ vid_id>
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<img src="#cloud_url#" border="0" width="120">
											<cfelse>
												<img src="#thestorage##path_to_asset#/#vid_name_image#" border="0" width="120">
											</cfif>
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0" width="128" height="128">
										</cfif>
									</cfif>
								</cfloop>	
							</a>				
						<cfelseif fav_kind EQ "aud">
							<a href="##" onclick="showwindow('#myself##xfa.audiodetail#&file_id=#myid#&what=audios&loaddiv=&folder_id=0','#thename#',1000,1);return false;">
								<cfloop query="qry_theaudio">
									<cfif myid EQ aud_id>
										<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif aud_extension EQ "mp3" OR aud_extension EQ "wav">#aud_extension#<cfelse>aud</cfif>.png" width="120" border="0">
									</cfif>
								</cfloop>
							</a>
						<cfelse>
							<a href="##" onclick="showwindow('#myself##xfa.filedetail#&file_id=#myid#&what=files&loaddiv=&folder_id=0','#thename#',1000,1);return false;">
								<cfloop query="qry_thefile">
									<cfif myid EQ file_id>
										<!--- Show the thumbnail --->
										<cfset thethumb = replacenocase(file_name_org, ".#file_extension#", ".jpg", "all")>
										<cfif application.razuna.storage EQ "amazon" AND cloud_url NEQ "">
											<img src="#cloud_url#" border="0" img-tt="img-tt">
										<cfelseif application.razuna.storage EQ "local" AND FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") >
											<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#thethumb#?#uniqueid#" border="0" img-tt="img-tt">
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" border="0" onerror = "this.src='#dynpath#/global/host/dam/images/icons/icon_txt.png'">
										</cfif>
									</cfif>
								</cfloop>	
							</a>
						</cfif>
					</cfif>
				<div style="padding-top:3px;font-weight:normal;"><a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_remove&id=#myid#');return false;">Remove</a></div>
				</td>
			</cfloop>
			</tr>
		</table>
	</cfif>
</cfoutput>