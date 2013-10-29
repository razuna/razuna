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
	<cfloop query="qry_av.assets">
		 <strong>#av_link_title#</strong> (<cfif av_type EQ "img" OR av_type EQ "vid">#thewidth#x#theheight# pixel</cfif> #myFusebox.getApplicationData().global.converttomb('#thesize#')# MB)<br />
			<a href="<cfif application.razuna.storage EQ "local">#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid#/#folder_id_r#/#av_type#/#av_id#/#urlencodedformat(av_link_title)#<cfelse>#av_link_url#</cfif>" target="_blank">View</a>
			| <a href="#myself#c.serve_file&file_id=#av_id#&type=#av_type#&v=o&av=true" target="_blank">Download</a>
			| <a href="##" onclick="toggleslide('divavo#av_id#','inputavo#av_id#');return false;">Direct Link</a>
			<cfif attributes.folderaccess NEQ "R">
				 | <a href="##" onclick="remavren('#av_id#','#av_type#');return false;">Remove</a>
			</cfif>
			<div id="divavo#av_id#" style="display:none;">
				<cfif application.razuna.storage EQ "local">
					<input type="text" id="inputavo#av_id#" style="width:100%;" value="#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid#/#folder_id_r#/#av_type#/#av_id#/#urlencodedformat(av_link_title)#" />
				<cfelse>
					<input type="text" id="inputavo#av_id#" style="width:100%;" value="#av_link_url#" />
				</cfif>		
			</div>
		<br />
	</cfloop>
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