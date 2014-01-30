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
<!---
<cfif application.razuna.storage EQ "nirvanix">
	<cfset thestorage = "#application.razuna.nvxurlservices#/#attributes.nvxsession#/razuna/#session.hostid#/">
<cfelse>
--->
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
<!--- </cfif> --->
<cfoutput>
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
	<tr>
		<th>#myFusebox.getApplicationData().defaults.trans("thumbnails")#</th>
		<th>#myFusebox.getApplicationData().defaults.trans("version_header")#</th>
		<th>#myFusebox.getApplicationData().defaults.trans("date_created")#</th>
		<th colspan="3"><a href="##" onclick="loadcontent('versionlist','#myself#c.versions_list&file_id=#attributes.file_id#&type=#attributes.type#&view=#createuuid()#');" style="align:right;">#myFusebox.getApplicationData().defaults.trans("reload")#</a></th>
	</tr>
	<cfloop query="qry_versions">
		<tr class="list">
			<!--- RAZ-2904::Thumbnail Preview --->
			<cfif application.razuna.storage EQ "local">
				<cfif (ver_type EQ "img" OR ver_type EQ "vid") OR (ver_type EQ "doc" AND ver_extension EQ "pdf")>
					<cfset thumb_img = '#thestorage#versions/#attributes.type#/#asset_id_r#/#ver_version#/#ver_thumbnail#'>	
				<cfelseif ver_type EQ "aud">
					<cfset thumb_img = '#dynpath#/global/host/dam/images/icons/icon_aud.png'>	
				<cfelseif ver_type EQ "doc" AND ver_extension EQ "doc"  >
					<cfset thumb_img = '#dynpath#/global/host/dam/images/icons/icon_doc.png'>	
				<cfelseif ver_type EQ "doc" AND ver_extension EQ "xlsx"  >
					<cfset thumb_img = '#dynpath#/global/host/dam/images/icons/icon_xlsx.png'>	
				<cfelse>
					<cfset thumb_img = '#dynpath#/global/host/dam/images/icons/image_missing.png'>
				</cfif>
			<cfelse>
				<cfif (ver_type EQ "img" OR ver_type EQ "vid") OR (ver_type EQ "doc" AND ver_extension EQ "pdf")>
					<cfset thumb_img = '#cloud_url_thumb#'>
				<cfelseif ver_type EQ "aud">
					<cfset thumb_img = '#dynpath#/global/host/dam/images/icons/icon_aud.png'>	
				<cfelseif ver_type EQ "doc" AND ver_extension EQ "doc"  >
					<cfset thumb_img = '#dynpath#/global/host/dam/images/icons/icon_doc.png'>	
				<cfelseif ver_type EQ "doc" AND ver_extension EQ "xlsx"  >
					<cfset thumb_img = '#dynpath#/global/host/dam/images/icons/icon_xlsx.png'>	
				<cfelse>
					<cfset thumb_img = '#dynpath#/global/host/dam/images/icons/image_missing.png'>
				</cfif>
			</cfif>
			<td>
				<a href="#thumb_img#" target="_blank"><img src="#thumb_img#" height="50" width="50"></a> 
			</td>
			<td><b>#ver_version#</b></td>
			<td width="100%">#dateformat(ver_date_add,"mmmm dd yyyy")# #timeformat(ver_date_add,"hh:mm:ss")#</td>
			<td valign="center" nowrap="true">
				<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
					<a href="#cloud_url_org#" target="_blank">
				<cfelse>
					<a href="#thestorage#versions/#attributes.type#/#asset_id_r#/#ver_version#/#ver_filename_org#" target="_blank">
				</cfif>	
				#myFusebox.getApplicationData().defaults.trans("show")#</a></td>
			<td valign="center" nowrap="true"><a href="##" onclick="verplayback('#asset_id_r#','#attributes.type#',#ver_version#);return false;">#myFusebox.getApplicationData().defaults.trans("playback")#</a></td>
			<td valign="center" nowrap="true"><a href="##" onclick="loadcontent('versionlist','#myself#c.versions_remove&file_id=#asset_id_r#&type=#attributes.type#&version=#ver_version#');return false;">#myFusebox.getApplicationData().defaults.trans("remove")#</a></td>
		</tr>
	</cfloop>
	<tr>
		<td colspan="5"><i>(#myFusebox.getApplicationData().defaults.trans("versions_cache")#)</i></td>
	</tr>
</table>
</cfoutput>