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
				<cfif asset_format EQ "thumb">
					<tr>
						<td><strong>#myFusebox.getApplicationData().defaults.trans("preview")#</strong><br>(#attributes.qry_detail.theprevsize# MB) #myFusebox.getApplicationData().defaults.trans("format")#: #ucase(attributes.qry_detail.detail.thumb_extension)# #myFusebox.getApplicationData().defaults.trans("size")#: #attributes.qry_detail.detail.thumbwidth#x#attributes.qry_detail.detail.thumbheight# pixel</td>
						<td valign="top"><cfif asset_dl OR qry_widget.widget_dl_thumb eq 't'><a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=p" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")#</a><cfelse>Not available</cfif></td>
					</tr>
				</cfif>
				<!--- Show original if allowed --->
				<cfif asset_format EQ "org">
					<tr>
						<td><strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong><br>(#attributes.qry_detail.thesize# MB) #myFusebox.getApplicationData().defaults.trans("format")#: #ucase(attributes.qry_detail.detail.img_extension)# #myFusebox.getApplicationData().defaults.trans("size")#: #attributes.qry_detail.detail.orgwidth#x#attributes.qry_detail.detail.orgheight# pixel</td>
						<td valign="top"><cfif asset_dl OR qry_widget.widget_dl_org eq 't'><a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=o" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")#</a><cfelse>Not available</cfif></td>
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
					<cfif asset_format EQ theid>
						<tr>
							<td><strong>#ucase(theext)#</strong><br><cfif theilength NEQ ""> (#myFusebox.getApplicationData().defaults.converttomb("#theilength#")# MB)</cfif> #myFusebox.getApplicationData().defaults.trans("size")#: #theorgwidth#x#theorgheight# pixel<br>[#attributes.qry_related.img_filename#]</td>
							<td valign="top"><cfif asset_dl><a href="#myself#c.serve_file&file_id=#theid#&type=img&v=o" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")#</a><cfelse>Not available</cfif></td>
						</tr>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<!--- Videos --->
		<cfif attributes.kind EQ "vid">
			<!--- Show original if allowed --->
			<cfloop query="qry_share_options">
				<cfif asset_format EQ "org">
					<tr>
						<td><strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong><br>(#attributes.qry_detail.thesize# MB) #myFusebox.getApplicationData().defaults.trans("format")#: #ucase(attributes.qry_detail.detail.vid_extension)# #myFusebox.getApplicationData().defaults.trans("size")#: #attributes.qry_detail.detail.vwidth#x#attributes.qry_detail.detail.vheight# pixel</td>
						<td valign="top"><cfif asset_dl OR qry_widget.widget_dl_org eq 't'><a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")#</a><cfelse>Not available</cfif></td>
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
					<cfif asset_format EQ theid>
						<tr>
							<td><strong>#ucase(theext)#</strong><br>(#myFusebox.getApplicationData().defaults.converttomb("#theilength#")# MB) #myFusebox.getApplicationData().defaults.trans("size")#: #theorgwidth#x#theorgheight# pixel<br>[#attributes.qry_related.vid_filename#]</td>
							<td valign="top"><cfif asset_dl><a href="#myself#c.serve_file&file_id=#theid#&type=vid&v=o" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")#</a><cfelse>Not available</cfif></td>
						</tr>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<!--- Audios --->
		<cfif attributes.kind EQ "aud">
			<!--- Show original if allowed --->
			<cfloop query="qry_share_options">
				<cfif asset_format EQ "org">
					<tr>
						<td><strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong><br>#myFusebox.getApplicationData().defaults.trans("format")#: #ucase(attributes.qry_detail.detail.aud_extension)#</td>
						<td valign="top"><cfif asset_dl OR qry_widget.widget_dl_org eq 't'><a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=aud" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")#</a><cfelse>Not available</cfif></td>
					</tr>
				</cfif>
			</cfloop>			
			<!--- Show converted --->
			<cfloop query="attributes.qry_related">
				<cfset theid = aud_id>
				<cfset theext = aud_extension>
				<cfset theilength = aud_size>
				<cfloop query="qry_share_options">
					<cfif asset_format EQ theid>
						<tr>
							<td><strong>#ucase(theext)#</strong><br>(#myFusebox.getApplicationData().defaults.converttomb("#theilength#")# MB)<br>[#attributes.qry_related.aud_name#]</td>
							<td valign="top"><cfif asset_dl><a href="#myself#c.serve_file&file_id=#theid#&type=aud" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")#</a><cfelse>Not available</cfif></td>
						</tr>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<!--- Documents --->
		<cfif attributes.kind EQ "doc">
			<!--- Show original if allowed --->
			<cfloop query="qry_share_options">
				<cfif asset_format EQ "org">
					<tr>
						<td><strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong><br>#myFusebox.getApplicationData().defaults.trans("format")#: #ucase(attributes.qry_detail.detail.file_extension)#</td>
						<td valign="top"><cfif asset_dl OR qry_widget.widget_dl_org eq 't'><a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=doc" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")#</a><cfelse>Not available</cfif></td>
					</tr>
				</cfif>
			</cfloop>
		</cfif>
		<!--- Additional versions --->
		<cfloop query="qry_av.assets">
			<cfset avid = av_id>
			<cfset av_link_url = av_link_url>
			<cfset av_link_title = av_link_title>
			<cfset hashtag = hashtag>
			<cfset thesize = thesize>
			<cfloop query="qry_share_options">
				<cfif asset_id_r EQ avid>
					<!--- Set correct download path --->
					<cfset thelinkurl = "#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid##av_link_url#">
					<tr>
						<td><strong>#av_link_title#</strong><br />(#myFusebox.getApplicationData().defaults.converttomb("#thesize#")# MB)</td>
						<td valign="top">
							<cfif qry_share_options.asset_dl>
								<a href="#thelinkurl#" target="_blank">#myFusebox.getApplicationData().defaults.trans("download")#</a>
							<cfelse>
								Not available
							</cfif>
						</td>
					</tr>
				</cfif>
			</cfloop>
		</cfloop>
	</table>
</cfoutput>