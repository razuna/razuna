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
<cfif qry_av.assets.recordcount NEQ 0 OR qry_av.links.recordcount NEQ 0>
	<br />
	<cfloop query="qry_av.links">
		<strong><a href="#av_link_url#" target="_blank">#av_link_title#</a></strong>
		<br />
	</cfloop>
	<br />
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<cfloop query="qry_av.assets">
		<tr>
			<cfif av_type eq 'img' >
				<td width="55" align="center">
					<cfif application.razuna.storage EQ 'local'>
					<cfset thumb_url = '#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid##qry_av.assets.av_thumb_url#'>
					<cfelse>
						<cfset thumb_url = '#qry_av.assets.av_thumb_url#'>
					</cfif>
					 <cfif qry_av.assets.av_thumb_url NEQ ""><a href="#thumb_url#" target="_blank"><img src="#thumb_url#" height="50"></a></cfif>
				</td><td width="5"></td>
			</cfif>
			<td valign="top">
				<strong>#av_link_title#</strong> (<cfif av_type EQ "img" OR av_type EQ "vid">#thewidth#x#theheight# pixel</cfif> #myFusebox.getApplicationData().global.converttomb('#thesize#')# MB)<br />
				<a href="<cfif application.razuna.storage EQ "local">#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid##av_link_url#<cfelse>#av_link_url#</cfif>" target="_blank">View</a>
				| <a href="#myself#c.serve_file&file_id=#av_id#&type=#av_type#&v=o&av=true" target="_blank">Download</a>
				| <a href="##" onclick="toggleslide('divavo#av_id#','inputavo#av_id#');return false;">Direct Link</a>
				| <a href="##" onclick="showwindow('#myself#c.rend_meta&file_id=#av_id#&thetype=#av_type#&cf_show=#av_type#&av=1','Metadata',550,2);return false;">Metadata</a>
				<cfif attributes.folderaccess NEQ "R">
					 | <a href="##" onclick="remavren('#av_id#','#av_type#');return false;">Remove</a>
				</cfif>
				<div id="divavo#av_id#" style="display:none;">
					<cfif application.razuna.storage EQ "local">
						<input type="text" id="inputavo#av_id#" style="width:100%;" value="#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid##av_link_url#" />
					<cfelse>
						<input type="text" id="inputavo#av_id#" style="width:100%;" value="#av_link_url#" />
					</cfif>		
				</div>
			</td>
		</tr>
		</cfloop>
	</table>
	<!--- Js --->
	<script type="text/javascript">
	function remavren(id,type){
		$( "##dialog-confirm-rendition" ).dialog({
			resizable: false,
			height:140,
			modal: true,
			buttons: {
				"Yes, remove rendition": function() {
					$( this ).dialog( "close" );
					$('##div_forall').load('#myself#c.av_link_remove_new&file_id=#attributes.file_id#&id=' + id, function(){ 
						if (type == 'img')loadren();
						if (type == 'vid')loadrenvid();
						if (type == 'aud')loadrenaud();
					});
				},
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			}
		});
	};
	</script>
</cfif>
</cfoutput>