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
	<cfset thestorage = "http://#cgi.http_host##cgi.script_name#?fa=">
	<cfset thestore = "#cgi.context_path#/assets/#session.hostid#/">
	<br />
	<div id="fileoptions">
		<!--- Images --->
		<cfif attributes.kind EQ "img">
			<!--- Show thumbnail --->
			<cfif qry_detail.detail.link_kind NEQ "url">
				<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
					<cfif cloud_url NEQ "">
						<img src="#qry_detail.detail.cloud_url#" border="0">
					<cfelse>
						<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
					</cfif>
				<cfelse>
					<img src="#thestore##qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#?#qry_detail.detail.hashtag#" border="0">
				</cfif>
			<cfelse>
				<img src="#qry_detail.detail.link_path_url#" border="0" width="120">
			</cfif>
			<!--- Show original if allowed --->
			<strong>Original</strong> <a href="#thestorage#c.si&f=#attributes.file_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=o">#myFusebox.getApplicationData().defaults.trans("download")# (#qry_detail.thesize# MB)</a>
			<br />
			#ucase(qry_detail.detail.img_extension)#, #qry_detail.detail.orgwidth#x#qry_detail.detail.orgheight# pixel<br />
			<br />
			<strong>Preview</strong> <a href="#thestorage#c.si&f=#attributes.file_id#&v=p" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=p">#myFusebox.getApplicationData().defaults.trans("download")# (#qry_detail.theprevsize# MB)</a>
			<br />
			#ucase(qry_detail.detail.thumb_extension)#, #qry_detail.detail.thumbwidth#x#qry_detail.detail.thumbheight# pixel
			<br />
			<!--- Show converted --->
			<cfloop query="qry_related">
				<br />
				<strong>#ucase(img_extension)#</strong> <a href="#thestorage#c.si&f=#img_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#img_id#&type=img&v=o">#myFusebox.getApplicationData().defaults.trans("download")#<cfif ilength NEQ ""> (#myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB)</cfif></a>
				<br />
				#myFusebox.getApplicationData().defaults.trans("size")#: #orgwidth#x#orgheight# pixel
				<br />
			</cfloop>
		<!--- Videos --->
		<cfelseif attributes.kind EQ "vid">
			<strong>Original</strong> <a href="#thestorage#c.si&f=#attributes.file_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid">#myFusebox.getApplicationData().defaults.trans("download")# (#qry_detail.thesize# MB)</a>
			<br />
			#ucase(qry_detail.detail.vid_extension)#, #qry_detail.detail.vwidth#x#qry_detail.detail.vheight# pixel
			<br />
			<!--- Show converted --->
			<cfloop query="qry_related">
				<br />
				#ucase(vid_extension)#</strong> <a href="#thestorage#c.si&f=#vid_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#vid_id#&type=vid&v=o">#myFusebox.getApplicationData().defaults.trans("download")# (#myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB)</a>
				<br />
				#vid_width#x#vid_height# pixel
				<br />
			</cfloop>
		<!--- Audios --->
		<cfelseif attributes.kind EQ "aud">
			<strong>Original</strong> <a href="#thestorage#c.si&f=#attributes.file_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=aud">#myFusebox.getApplicationData().defaults.trans("download")# (#myFusebox.getApplicationData().defaults.converttomb("#qry_detail.detail.aud_size#")# MB)</a>
			<br />
			#ucase(qry_detail.detail.aud_extension)#
			<br />
			<!--- Show converted --->
			<cfloop query="qry_related">
				<br />
				<strong>#ucase(aud_extension)#</strong> <a href="#thestorage#c.si&f=#aud_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#aud_id#&type=aud">#myFusebox.getApplicationData().defaults.trans("download")# (#myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB)</a>
				<br />
			</cfloop>
		<!--- Documents --->
		<cfelse>
			<a href="#thestorage#c.serve_file&file_id=#file_id#&type=doc" target="_blank">Download file</a>
		</cfif>
	</div>
	<div style="clear:both;padding-bottom:10px;"></div>
</cfoutput>