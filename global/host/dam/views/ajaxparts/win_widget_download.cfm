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
<!--- Define variables --->
<cfoutput>
	<table border="0" cellpadding="5" cellspacing="5" width="100%" class="grid">
		<!--- Images --->
		<cfif attributes.kind EQ "img">
			<!--- Preview --->
			<cfloop query="qry_share_options">
				<cfif asset_format EQ "thumb" AND asset_dl>
					<tr>
						<td><strong>Preview</strong><br>(#attributes.qry_detail.theprevsize# MB) #defaultsObj.trans("format")#: #ucase(attributes.qry_detail.detail.thumb_extension)# #defaultsObj.trans("size")#: #attributes.qry_detail.detail.thumbwidth#x#attributes.qry_detail.detail.thumbheight# pixel</td>
						<td valign="top"><a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=p">#defaultsObj.trans("download")#</a></td>
					</tr>
				</cfif>
				<!--- Show original if allowed --->
				<cfif asset_format EQ "org" AND asset_dl>
					<tr>
						<td><strong>Original</strong><br>(#attributes.qry_detail.thesize# MB) #defaultsObj.trans("format")#: #ucase(attributes.qry_detail.detail.img_extension)# #defaultsObj.trans("size")#: #attributes.qry_detail.detail.orgwidth#x#attributes.qry_detail.detail.orgheight# pixel</td>
						<td valign="top"><a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=o">#defaultsObj.trans("download")#</a></td>
					</tr>
				</cfif>
			</cfloop>
			<!--- Show converted --->
			<cfloop query="attributes.qry_related">
				<cfset theid = img_id>
				<cfset theext = img_extension>
				<cfset theilength = ilength>
				<cfset theorgwidth = orgwidth>
				<cfset theorgheight = orgheight>
				<cfloop query="qry_share_options">
					<cfif asset_format EQ theid AND asset_dl>
						<tr>
							<td><strong>#ucase(theext)#</strong><br><cfif theilength NEQ ""> (#defaultsObj.converttomb("#theilength#")# MB)</cfif> #defaultsObj.trans("size")#: #theorgwidth#x#theorgheight# pixel</td>
							<td valign="top"><a href="#myself#c.serve_file&file_id=#theid#&type=img&v=o">#defaultsObj.trans("download")#</a></td>
						</tr>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<!--- Videos --->
		<cfif attributes.kind EQ "vid">
			<!--- Show original if allowed --->
			<cfloop query="qry_share_options">
				<cfif asset_format EQ "org" AND asset_dl>
					<tr>
						<td><strong>Original</strong><br>(#attributes.qry_detail.thesize# MB) #defaultsObj.trans("format")#: #ucase(attributes.qry_detail.detail.vid_extension)# #defaultsObj.trans("size")#: #attributes.qry_detail.detail.vwidth#x#attributes.qry_detail.detail.vheight# pixel</td>
						<td valign="top"><a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid">#defaultsObj.trans("download")#</a></td>
					</tr>
				</Cfif>
			</cfloop>
			<!--- Show converted --->
			<cfloop query="attributes.qry_related">
				<cfset theid = vid_id>
				<cfset theext = vid_extension>
				<cfset theilength = vlength>
				<cfset theorgwidth = vid_width>
				<cfset theorgheight = vid_height>
				<cfloop query="qry_share_options">
					<cfif asset_format EQ theid AND asset_dl>
						<tr>
							<td><strong>#ucase(theext)#</strong><br>(#defaultsObj.converttomb("#theilength#")# MB) #defaultsObj.trans("size")#: #theorgwidth#x#theorgheight# pixel</td>
							<td valign="top"><a href="#myself#c.serve_file&file_id=#theid#&type=vid&v=o">#defaultsObj.trans("download")#</a></td>
						</tr>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<!--- Audios --->
		<cfif attributes.kind EQ "aud">
			<!--- Show original if allowed --->
			<cfloop query="qry_share_options">
				<cfif asset_format EQ "org" AND asset_dl>
					<tr>
						<td><strong>Original</strong><br>#defaultsObj.trans("format")#: #ucase(attributes.qry_detail.detail.aud_extension)#</td>
						<td valign="top"><a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=aud">#defaultsObj.trans("download")#</a></td>
					</tr>
				</cfif>
			</cfloop>			
			<!--- Show converted --->
			<cfloop query="attributes.qry_related">
				<cfset theid = aud_id>
				<cfset theext = aud_extension>
				<cfset theilength = aud_size>
				<cfloop query="qry_share_options">
					<cfif asset_format EQ theid AND asset_dl>
						<tr>
							<td><strong>#ucase(theext)#</strong><br>(#defaultsObj.converttomb("#theilength#")# MB)</td>
							<td valign="top"><a href="#myself#c.serve_file&file_id=#theid#&type=aud">#defaultsObj.trans("download")#</a></td>
						</tr>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
	</table>
</cfoutput>