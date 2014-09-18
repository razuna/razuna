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
	<cfset thestorage = "#session.thehttp##cgi.http_host##cgi.script_name#?fa=">
	<cfset thestore = "#cgi.context_path#/assets/#session.hostid#/">
	<br />
	<div id="fileoptions">
		<!--- Images --->
		<cfif attributes.kind EQ "img">
			<div id="filesimg">
				<!--- Show thumbnail --->
				<cfif qry_detail.detail.link_kind NEQ "url">
					<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
						<cfif qry_detail.detail.cloud_url NEQ "">
							<img src="#qry_detail.detail.cloud_url#" border="0">
						<cfelse>
							<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
						</cfif>
					<cfelse>
						<img src="#thestore##qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#?#qry_detail.detail.hashtag#" border="0">
					</cfif>
				<cfelse>
					<img src="#qry_detail.detail.link_path_url#" border="0">
				</cfif>
			</div>
			<div style="clear:both;"></div>
			<!--- Show original if allowed --->
			<strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong> <a href="#thestorage#c.si&f=#attributes.file_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=o" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")# (#qry_detail.thesize# MB)</a>
			<br />
			#ucase(qry_detail.detail.img_extension)#, #qry_detail.detail.orgwidth#x#qry_detail.detail.orgheight# pixel<br />
			<br />
			<strong>#myFusebox.getApplicationData().defaults.trans("preview")#</strong> <a href="#thestorage#c.si&f=#attributes.file_id#&v=p" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=p" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")# (#qry_detail.theprevsize# MB)</a>
			<br />
			#ucase(qry_detail.detail.thumb_extension)#, #qry_detail.detail.thumbwidth#x#qry_detail.detail.thumbheight# pixel
			<br />
			<!--- Show converted --->
			<cfloop query="qry_related">
				<br />
				<strong>#ucase(img_extension)#</strong> <a href="#thestorage#c.si&f=#img_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#img_id#&type=img&v=o" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")#<cfif ilength NEQ ""> (#myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB)</cfif></a>
				<br />
				#myFusebox.getApplicationData().defaults.trans("size")#: #orgwidth#x#orgheight# pixel
				<br />
			</cfloop>
		<!--- Videos --->
		<cfelseif attributes.kind EQ "vid">
			<div id="filesimg">
				<cfif qry_detail.detail.link_kind NEQ "url">
					<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
						<cfif qry_detail.detail.cloud_url NEQ "">
							<img src="#qry_detail.detail.cloud_url#" border="0">
						<cfelse>
							<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
						</cfif>
					<cfelse>
						<img src="#thestore##qry_detail.detail.path_to_asset#/#qry_detail.detail.vid_name_image#?#qry_detail.detail.hashtag#" border="0">
					</cfif>
				<cfelse>
					<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
				</cfif>
			</div>
			<div style="clear:both;"></div>
			<strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong> <a href="#thestorage#c.sv&f=#attributes.file_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")# (#qry_detail.thesize# MB)</a>
			<br />
			#ucase(qry_detail.detail.vid_extension)#, #qry_detail.detail.vwidth#x#qry_detail.detail.vheight# pixel
			<br />
			<!--- Show converted --->
			<cfloop query="qry_related">
				<br />
				#ucase(vid_extension)#</strong> <a href="#thestorage#c.sv&f=#vid_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#vid_id#&type=vid&v=o" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")# (#myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB)</a>
				<br />
				#vid_width#x#vid_height# pixel
				<br />
			</cfloop>
		<!--- Audios --->
		<cfelseif attributes.kind EQ "aud">
			<!--- <div id="filesimg">
				<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif qry_detail.detail.aud_extension EQ "mp3" OR qry_detail.detail.aud_extension EQ "wav">#qry_detail.detail.aud_extension#<cfelse>aud</cfif>.png" border="0">
			</div>
			<div style="clear:both;"></div> --->
			<strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong> <a href="#thestorage#c.sa&f=#attributes.file_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=aud" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")# (#myFusebox.getApplicationData().defaults.converttomb("#qry_detail.detail.aud_size#")# MB)</a>
			<br />
			#ucase(qry_detail.detail.aud_extension)#
			<br />
			<!--- Show converted --->
			<cfloop query="qry_related">
				<br />
				<strong>#ucase(aud_extension)#</strong> <a href="#thestorage#c.si&f=#aud_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#aud_id#&type=aud" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")# (#myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB)</a>
				<br />
			</cfloop>
		<!--- Documents --->
		<cfelse>
			<div id="filesimg">
				<!--- If it is a PDF we show the thumbnail --->
				<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND qry_detail.detail.file_extension EQ "PDF">
					<cfif qry_detail.detail.cloud_url NEQ "">
						<img src="#qry_detail.detail.cloud_url#" border="0">
					<cfelse>
						<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
					</cfif>
				<cfelseif application.razuna.storage EQ "local" AND qry_detail.detail.file_extension EQ "PDF">
					<cfset thethumb = replacenocase(qry_detail.detail.file_name_org, ".pdf", ".jpg", "all")>
					<cfif FileExists("#attributes.assetpath#/#session.hostid#/#qry_detail.detail.path_to_asset#/#thethumb#") IS "no">
						<img src="#dynpath#/global/host/dam/images/icons/icon_#qry_detail.detail.file_extension#.png" border="0">
					<cfelse>
						<img src="#dynpath#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#thethumb#" width="120" border="0">
					</cfif>
				<cfelse>
					<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#qry_detail.detail.file_extension#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#qry_detail.detail.file_extension#.png" width="120" height="120" border="0"></cfif>
				</cfif>
			</div>
			<a href="#thestorage#c.serve_file&file_id=#file_id#&type=doc" target="_blank">Download (#myFusebox.getApplicationData().defaults.converttomb("#qry_detail.thesize#")# MB)</a>
		</cfif>
	</div>
	<div style="clear:both;padding-bottom:10px;"></div>
</cfoutput>