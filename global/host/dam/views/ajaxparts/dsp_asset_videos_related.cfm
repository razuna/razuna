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
<!--- <cfdump var="#qry_related#"> --->
<cfoutput>
<cfif qry_related.recordcount NEQ 0>
	<br />
	<table boder="0" cellpadding="0" cellspacing="0" width="100%">
		<cfloop query="qry_related">
			<tr>
				<td width="65" align="center">
					<!--- Thumbnail --->
					<cfif link_kind NEQ "lan">
						<cfif link_kind EQ "url">
							<cfif link_path_url contains "http">
								<a href="#link_path_url#" target="_blank">#link_path_url#</a>
							<cfelse>
								#link_path_url#
							</cfif>
						<cfelse>
							<a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sv&f=#attributes.file_id#&v=o" target="_blank"><img src="<cfif application.razuna.storage EQ "local">#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#vid_name_image#?_v=#hashtag#<cfelse>#cloud_url#</cfif>" style="max-height:50px;max-width:100px;"></a>
						</cfif>
					<cfelse>
						<cfif shared EQ "F"><a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sv&f=#attributes.file_id#&v=o" target="_blank"><cfelse><a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#vid_name_org#" target="_blank"></cfif>
							<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#vid_name_image#?_v=#hashtag#" border="0" style="max-height:50px;max-width:100px;">
						</a>
					</cfif>
				</td>
				<td nowrap="true">
					<cfif attributes.s EQ "F">
						<strong>#ucase(vid_extension)#</strong> (#myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB, #vid_width#x#vid_height# pixel) [#vid_filename#]<br />
						<button type="button" class="awesome small green" onclick="window.open('#myself#c.serve_file&file_id=#vid_id#&type=vid','_blank');">#myFusebox.getApplicationData().defaults.trans("download")#</button>
						<a href="//#cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sv&f=#vid_id#&v=o" target="_blank" style="padding-left:20px;">
					<cfelse>
						<button type="button" class="awesome small green" onclick="window.open('#myself#c.serve_file&file_id=#vid_id#&type=vid','_blank');">#myFusebox.getApplicationData().defaults.trans("download")#</button>
						<a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#vid_name_org#" target="_blank" style="padding-left:20px;">
					</cfif>
					#myFusebox.getApplicationData().defaults.trans("view_link")#</a>
					 | <a href="##" onclick="toggleslide('divo#vid_id#','inputo#vid_id#');return false;">#myFusebox.getApplicationData().defaults.trans("direct_link")#</a>
					 | <a href="##" onclick="toggleslide('dive#vid_id#','inpute#vid_id#');return false;">#myFusebox.getApplicationData().defaults.trans("embed")#</a>
					 <cfif cs.show_metadata_link>
					 | <a href="##" onclick="showwindow('#myself#c.rend_meta&file_id=#vid_id#&thetype=vid&cf_show=vid','Metadata',550,2);return false;">#myFusebox.getApplicationData().defaults.trans("metadata")#</a>
 					</cfif>
					 | <a href="##" onclick="showwindow('#myself#c.exist_rendition_videos&file_id=#vid_id#&vid_group_id=#vid_group#&thetype=vid&cf_show=vid&folder_id=#folder_id#&what=#what#','Renditions',875,2);return false;">#myFusebox.getApplicationData().defaults.trans("create_new_renditions")#</a>
					<cfif attributes.folderaccess NEQ "R">
						 | <a href="##" onclick="remren('#vid_id#');">#myFusebox.getApplicationData().defaults.trans("delete")#</a>
					</cfif>
					<div id="divo#vid_id#" style="display:none;">
						<input type="text" id="inputo#vid_id#" style="width:100%;" value="//#cgi.http_host##cgi.script_name#?#theaction#=c.sv&f=#vid_id#&v=o" />
						<br />
						<cfif application.razuna.storage EQ "local">
							<input type="text" id="inputo#vid_id#d" style="width:100%;" value="//#cgi.http_host##dynpath#/assets/#session.hostid#/#path_to_asset#/#vid_name_org#" />
						<cfelse>
							<input type="text" id="inputo#vid_id#d" style="width:100%;" value="#cloud_url_org#" />
						</cfif>
						<!--- Plugin --->
						<cfset args = structNew()>
						<cfset args.detail.vid_id = vid_id>
						<cfset args.detail.path_to_asset = path_to_asset>
						<cfset args.detail.vid_name_org = vid_filename>
						<cfset args.thefiletype = "vid">
						<cfinvoke component="global.cfc.plugins" method="getactions" theaction="show_in_direct_link" args="#args#" returnvariable="pl">
						<!--- Show plugin --->
						<cfif structKeyExists(pl,"pview")>
							<cfloop list="#pl.pview#" delimiters="," index="i">
								<br />
								#evaluate(i)#
							</cfloop>
						</cfif>
					</div>
					<div id="dive#vid_id#" style="display:none;">
						<cfset eh = vid_height ? vid_height + 40 : 50>
						<textarea id="inpute#vid_id#" style="width:500px;height:60px;" readonly="readonly"><iframe frameborder="0" src="//#cgi.http_host##cgi.script_name#?#theaction#=c.sv&f=#vid_id#&v=o" scrolling="auto" width="100%" height="#eh#"></iframe></textarea>
					</div>
				</td>
			</tr>
		</cfloop>
	</table>
</cfif>
<div id="dialog-confirm-rendition" title="#myFusebox.getApplicationData().defaults.trans("remove_rend_confirm")#" style="display:none;">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>#myFusebox.getApplicationData().defaults.trans("remove_rend")#</p>
</div>
<!--- Js --->
<script type="text/javascript">
function remren(id){
	$( "##dialog-confirm-rendition" ).dialog({
		resizable: false,
		height:140,
		modal: true,
		buttons: {
			"#myFusebox.getApplicationData().defaults.trans("remove_rend_ok")#": function() {
				$( this ).dialog( "close" );
				$('##relatedvideos').load('#myself#c.videos_remove_related&file_id=#attributes.file_id#&what=videos&loaddiv=#attributes.loaddiv#&folder_id=#attributes.folder_id#&s=#attributes.s#&id=' + id, function(){ loadrenvid(); });
			},
			"#myFusebox.getApplicationData().defaults.trans('cancel')#": function() {
				$( this ).dialog( "close" );
			}
		}
	});
};
</script>
</cfoutput>