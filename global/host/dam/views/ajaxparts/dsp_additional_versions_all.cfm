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
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<cfloop query="qry_av.assets">
			<!--- Format size --->
			<cfif isnumeric(thesize)><cfset thesize = numberformat(thesize,'_.__')></cfif>
			<tr>
				<cfif av_type eq 'img' >
					<td width="75" align="center">
						<cfif application.razuna.storage EQ 'local'>
							<cfset thumb_url = '#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid##qry_av.assets.av_thumb_url#'>
						<cfelse>
							<cfset thumb_url = '#qry_av.assets.av_thumb_url#'>
						</cfif>
						 <cfif qry_av.assets.av_thumb_url NEQ ""><a href="#thumb_url#" target="_blank"><img src="#thumb_url#" style="max-height:50px;max-width:100px;padding-right:10px;"></a></cfif>
					</td>
				</cfif>
				<td valign="top">
					<strong>#av_link_title#</strong> (<cfif av_type EQ "img" OR av_type EQ "vid">#thewidth#x#theheight# pixel</cfif> #myFusebox.getApplicationData().global.converttomb('#thesize#')# MB)
					<br />
					<a href="#myself#c.serve_file&file_id=#av_id#&type=#av_type#&v=o&av=true" target="_blank" style="color:white;text-decoration:none;"><button type="button" class="awesome small green">#myFusebox.getApplicationData().defaults.trans("download")#</button></a>
					<a href="##" onclick="toggleslide('divavo#av_id#','inputavo#av_id#');return false;" style="padding-left:20px;">Direct Link</a>
					| <a href="##" onclick="showwindow('#myself#c.rend_meta&file_id=#av_id#&thetype=#av_type#&cf_show=#av_type#&av=1','Metadata',550,2);return false;">Metadata</a>
					<cfif attributes.folderaccess NEQ "R">
						 | <a href="##" onclick="remavren('#av_id#','#av_type#');return false;">Remove</a>
						 <cfif isdefined("attributes.isdoc") AND av_type eq 'doc'>| <a href="##" onclick="swaporiginal('#av_id#','#av_type#');return false;">#myFusebox.getApplicationData().defaults.trans("swap_original")#</a></cfif>
						<cfif av_type eq 'img'>| <a href="##" onclick="useforpreview('#av_id#','#av_type#');return false;">Use as #myFusebox.getApplicationData().defaults.trans("preview")# Image</a></cfif>
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
	<cfloop query="qry_av.links">
		<strong><a href="#av_link_url#" target="_blank">#av_link_title#</a></strong>
		<br />
	</cfloop>
	<div id="msg"></div>
	<div id="dialog-confirm-swap" title="Swap with Original?" style="display:none;">
		<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>The Original will be replaced by this rendition and vice versa. Are you sure you wish to continue?</p>
	</div>
	<div id="dialog-confirm-rendition" title="Really remove this rendition?" style="display:none;">
		<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>The rendition will be permanently deleted and cannot be recovered. Are you sure?</p>
	</div>
	<!--- Js --->
	<script type="text/javascript">
	function swaporiginal(id, type){
		$( "##dialog-confirm-swap" ).dialog({
			resizable: false,
			height:160,
			modal: true,
			buttons: {
				"Yes": function() {
					$( this ).dialog( "close" );
					$('##div_forall').load('#myself#c.swap_rendition_original&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&id=' + id, function(){ 
						if (type == 'img')loadren();
						if (type == 'vid')loadrenvid();
						if (type == 'aud')loadrenaud();
						$('##msg').html('<font color=steelblue">The rendition has been swapped. Please reload the page to see changes.</font>');
					 });
				},
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			}
		});
	};
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
						if (type == 'doc')loadcontent('additionalversions','#myself#c.av_load&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&isdoc=yes');
					});
				},
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			}
		});
	};
	function useforpreview(av_id,type){
			$('##div_forall').load('#myself#c.use_rendition_for_preview&userendforpreview=1&file_id=#attributes.file_id#&av_id=' + av_id + '&type=' + type);
			$('##msg').html('<font color=steelblue">The preview has been updated. Please reload the page to see changes.</font>');

	};
	</script>
</cfif>
</cfoutput>