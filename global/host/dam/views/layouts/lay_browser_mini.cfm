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
	<!--- For file detail --->
	<cfif attributes.file_id NEQ 0>
		<div><a href="#myself#c.mini_browser&folder_id=#attributes.folder_id#" style="text-decoration:none;"><img src="#dynpath#/global/host/dam/images/go-up-5.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"><span style="color:green;font-weight:bold;">Go back</span></a></div>
		<br />
		<!--- Images --->
		<cfif attributes.kind EQ "img">
			<!--- Show original if allowed --->
			<strong>Original</strong> (#qry_detail.thesize# MB) #myFusebox.getApplicationData().defaults.trans("format")#: #ucase(qry_detail.detail.img_extension)# #myFusebox.getApplicationData().defaults.trans("size")#: #qry_detail.detail.orgwidth#x#qry_detail.detail.orgheight# pixel
			<br />
			<a href="#thestorage#c.si&f=#attributes.file_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=o">#myFusebox.getApplicationData().defaults.trans("download")#</a>
			<br />
			<strong>Preview</strong> (#qry_detail.theprevsize# MB) #myFusebox.getApplicationData().defaults.trans("format")#: #ucase(qry_detail.detail.thumb_extension)# #myFusebox.getApplicationData().defaults.trans("size")#: #qry_detail.detail.thumbwidth#x#qry_detail.detail.thumbheight# pixel
			<br />
			<a href="#thestorage#c.si&f=#attributes.file_id#&v=p" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=p">#myFusebox.getApplicationData().defaults.trans("download")#</a>
			<!--- Show converted --->
			<cfloop query="qry_related">
				<br />
				<strong>#ucase(img_extension)#</strong> <cfif ilength NEQ ""> (#myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB)</cfif> #myFusebox.getApplicationData().defaults.trans("size")#: #orgwidth#x#orgheight# pixel
				<br />
				<a href="#thestorage#c.si&f=#img_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#img_id#&type=img&v=o">#myFusebox.getApplicationData().defaults.trans("download")#</a>
			</cfloop>
		</cfif>
		<!--- Videos --->
		<cfif attributes.kind EQ "vid">
			<strong>Original</strong> (#qry_detail.thesize# MB) #myFusebox.getApplicationData().defaults.trans("format")#: #ucase(qry_detail.detail.vid_extension)# #myFusebox.getApplicationData().defaults.trans("size")#: #qry_detail.detail.vwidth#x#qry_detail.detail.vheight# pixel
			<br />
			<a href="#thestorage#c.si&f=#attributes.file_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid">#myFusebox.getApplicationData().defaults.trans("download")#</a>
			<!--- Show converted --->
			<cfloop query="qry_related">
				<br />
				#ucase(vid_extension)#</strong> (#myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB) #myFusebox.getApplicationData().defaults.trans("size")#: #vid_width#x#vid_height# pixel
				<br />
				<a href="#thestorage#c.si&f=#vid_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#vid_id#&type=vid&v=o">#myFusebox.getApplicationData().defaults.trans("download")#</a>
			</cfloop>
		</cfif>
		<!--- Audios --->
		<cfif attributes.kind EQ "aud">
			<strong>Original</strong> #myFusebox.getApplicationData().defaults.trans("format")#: #ucase(qry_detail.detail.aud_extension)#
			<br />
			<a href="#thestorage#c.si&f=#attributes.file_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=aud">#myFusebox.getApplicationData().defaults.trans("download")#</a>
			<!--- Show converted --->
			<cfloop query="qry_related">
				<br />
				<strong>#ucase(aud_extension)#</strong> (#myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB)
				<br />
				<a href="#thestorage#c.si&f=#aud_id#&v=o" target="_blank">View</a> | <a href="#myself#c.serve_file&file_id=#aud_id#&type=aud">#myFusebox.getApplicationData().defaults.trans("download")#</a>
			</cfloop>
		</cfif>
	<!--- Browsing folder and files --->
	<cfelse>
		<div>There are #qry_subfolders.recordcount# folders and #qry_filecount.thetotal# files here.</div>
		<br>
		<!--- Foldername --->
		<cfif qry_foldername NEQ "">
			<div id="foldername">#qry_foldername#</div>
		</cfif>
		<cfif attributes.folder_id NEQ 0>
			<cfif qry_folder.folder_id EQ qry_folder.folder_id_r><cfset fid = 0><cfelse><cfset fid = qry_folder.folder_id_r></cfif>
			<div id="parentfolder"><a href="#myself#c.mini_browser&folder_id=#fid#" style="text-decoration:none;"><img src="#dynpath#/global/host/dam/images/go-up-5.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"><span style="color:green;">Parent Folder</style></a></div>
		</cfif>
		<cfloop query="qry_subfolders">
			<div id="folders"><a href="#myself#c.mini_browser&folder_id=#folder_id#"><img src="#dynpath#/global/host/dam/images/folder-yellow_16.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left">#folder_name#</a></div>
		</cfloop>
		<cfloop query="qry_files">
			<div id="files"<cfif qry_files.recordcount NEQ 1> class="list"</cfif>><cfif kind EQ "img"><a href="#myself#c.mini_browser&folder_id=#folder_id#&file_id=#id#&kind=#kind#"><img src="#dynpath#/global/host/dam/images/image-x-generic.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"><cfelseif kind EQ "vid"><a href="#myself#c.mini_browser&folder_id=#folder_id#&file_id=#id#&kind=#kind#"><img src="#dynpath#/global/host/dam/images/video-x-generic.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"><cfelseif kind EQ "aud"><a href="#myself#c.mini_browser&folder_id=#folder_id#&file_id=#id#&kind=#kind#"><img src="#dynpath#/global/host/dam/images/audio-x-generic.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"><cfelse><a href="#myself#c.serve_file&file_id=#id#&type=doc" target="_blank"><img src="#dynpath#/global/host/dam/images/x-office-document-2.png" border="0" style="padding-right:5px;margin-top:-1px;" align="left"></cfif>#filename#</a></div>
		</cfloop>
	</cfif>
</cfoutput>
