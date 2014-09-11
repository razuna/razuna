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
<cfif qry_related.recordcount NEQ 0>
	<br />
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<cfloop query="qry_related">
			<tr>
				<td width="65" align="center">
					 <!--- Thumbnail --->
					 <cfset args = structNew()>
					 <cfset args.thumb_img_id= img_id>
					 <cfinvoke component="global.cfc.global" method="get_share_options" thestruct="#args#" returnvariable="qry_share_options">
					 <cfif application.razuna.storage EQ 'local' AND qry_share_options.group_asset_id NEQ ''> 
					 	<a href="#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid#/#path_to_asset#/thumb_#qry_share_options.group_asset_id#.#qry_related.thumb_extension#" target="_blank">
					 		<img src="#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid#/#path_to_asset#/thumb_#qry_share_options.group_asset_id#.#qry_related.thumb_extension#" height="50">
					 	</a>
					 <cfelse>
					 	<a href="#cloud_url#" target="_blank"><img src="#cloud_url#" height="50"></a>
					 </cfif>
				</td>
				<td width="10"></td>
				<td valign="top">
					<strong>#ucase(img_extension)#</strong> (#orgwidth#x#orgheight# pixel<cfif ilength NEQ "">, #myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB</cfif><cfif img_meta NEQ "">, #img_meta# dpi</cfif>)  [#img_filename#]<br />
					<cfif attributes.s EQ "F">
						<a href="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#img_id#&v=o" target="_blank">
					<cfelse>
						<a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#img_filename_org#" target="_blank">
					</cfif>
					</a> 
					<a href="#myself#c.serve_file&file_id=#img_id#&type=img&v=o" style="color:white;text-decoration:none;"><button type="button" class="awesome small green">#myFusebox.getApplicationData().defaults.trans("download")#</button></a>
					<a href="##" onclick="toggleslide('divo#img_id#','inputo#img_id#');return false;" style="padding-left:20px;">Direct Link</a>
					 | <a href="##" onclick="showwindow('#myself#c.rend_meta&file_id=#img_id#&thetype=img&cf_show=img','Metadata',550,2);return false;">Metadata</a>
					 <cfif attributes.folderaccess NEQ "R">
						 | <a href="##" onclick="showwindow('#myself#c.exist_rendition_images&file_id=#img_id#&img_group_id=#img_group#&thetype=img&cf_show=img&folder_id=#folder_id#&what=#what#','Renditions',875,2);return false;">#myFusebox.getApplicationData().defaults.trans("create_new_renditions")#</a>
						 | <a href="##" onclick="remren('#img_id#');return false;">#myFusebox.getApplicationData().defaults.trans("delete")#</a>
					</cfif>
					<div id="divo#img_id#" style="display:none;">
						<input type="text" id="inputo#img_id#" style="width:100%;" value="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#img_id#&v=o" />
						<cfif application.razuna.storage EQ "local">
							<input type="text" id="inputo#img_id#d" style="width:100%;" value="#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid#/#path_to_asset#/#img_filename_org#" />
						<cfelse>
							<input type="text" id="inputo#img_id#d" style="width:100%;" value="#cloud_url_org#" />
						</cfif>
						<!--- Plugin --->
						<cfset args = structNew()>
						<cfset args.detail.img_id = img_id>
						<cfset args.detail.path_to_asset = path_to_asset>
						<cfset args.detail.img_filename_org = img_filename>
						<cfset args.thefiletype = "img">
						<cfinvoke component="global.cfc.plugins" method="getactions" theaction="show_in_direct_link" args="#args#" returnvariable="pl">
						<!--- Show plugin --->
						<cfif structKeyExists(pl,"pview")>
							<cfloop list="#pl.pview#" delimiters="," index="i">
								#evaluate(i)#
							</cfloop>
						</cfif>
					</div>
					<br>
					<!--- Nirvanix --->
					<cfif application.razuna.storage EQ "nirvanix" AND attributes.s EQ "T">
						<i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#img_filename#</i>
						<br>
					</cfif>
				</td>
			</tr>
		</cfloop>
	</table>
</cfif>
<div id="dialog-confirm-rendition" title="Really remove this rendition?" style="display:none;">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>The rendition will be permanently deleted and cannot be recovered. Are you sure?</p>
</div>
<!--- Js --->
<script type="text/javascript">
function remren(id){
	$( "##dialog-confirm-rendition" ).dialog({
		resizable: false,
		height:140,
		modal: true,
		buttons: {
			"Yes, remove rendition": function() {
				$( this ).dialog( "close" );
				$('##div_forall').load('#myself#c.images_remove_related&file_id=#attributes.file_id#&what=images&loaddiv=#attributes.loaddiv#&folder_id=#attributes.folder_id#&s=#attributes.s#&id=' + id, function(){ loadren(); });
			},
			Cancel: function() {
				$( this ).dialog( "close" );
			}
		}
	});
};
</script>
</cfoutput>