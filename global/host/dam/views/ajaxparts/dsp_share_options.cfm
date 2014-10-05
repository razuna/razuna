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
<cfif session.hosttype EQ 0>
	<cfinclude template="dsp_host_upgrade.cfm">
<cfelse>
	<cfset thumbdl = 0>
	<cfset thumbor = 0>
	<cfset thumbsel = 0>
	<cfset orgdl = 0>
	<cfset orgor = 0>
	<cfset orgsel = 0>
	<!--- Thumbnail --->
	<cfloop query="qry_share_options">
		<cfif asset_id_r EQ attributes.file_id AND asset_format EQ "thumb" AND asset_dl>
			<cfset thumbdl = 1>
		</cfif>
		<cfif asset_id_r EQ attributes.file_id AND asset_format EQ "thumb" AND asset_order>
			<cfset thumbor = 1>
		</cfif>
		<cfif asset_id_r EQ attributes.file_id AND asset_format EQ "thumb" AND asset_selected>
			<cfset thumbsel = 1>
		</cfif>
		<cfif asset_id_r EQ attributes.file_id AND asset_format EQ "org" AND asset_dl>
			<cfset orgdl = 1>
		</cfif>
		<cfif asset_id_r EQ attributes.file_id AND asset_format EQ "org" AND asset_order>
			<cfset orgor = 1>
		</cfif>
		<cfif asset_id_r EQ attributes.file_id AND asset_format EQ "org" AND asset_selected>
			<cfset orgsel = 1>
		</cfif>
	</cfloop>
	<!--- Values by type --->
	<cfif attributes.type EQ "img">
		<cfset thumbext = qry_detail.thumb_extension>
		<cfset thumbsize = qry_detail.thumb_size>
		<cfset thumbw = qry_detail.thumb_width>
		<cfset thumbh = qry_detail.thumb_height>
		<cfset orgext = qry_detail.img_extension>
		<cfset orgsize = qry_detail.img_size>
		<cfset orgw = qry_detail.img_width>
		<cfset orgh = qry_detail.img_height>
	<cfelseif attributes.type EQ "vid">
		<cfset orgext = qry_detail.vid_extension>
		<cfset orgsize = qry_detail.vid_size>
		<cfset orgw = qry_detail.vid_width>
		<cfset orgh = qry_detail.vid_height>
	<cfelseif attributes.type EQ "aud">
		<cfset orgext = qry_detail.detail.aud_extension>
		<cfset orgsize = qry_detail.detail.aud_size>
		<cfset qry_detail.link_kind = qry_detail.detail.link_kind>
	<cfelseif attributes.type EQ "doc">
		<cfset orgext = qry_detail.file_extension>
		<cfset orgsize = qry_detail.file_size>
	</cfif>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<td colspan="4">#myFusebox.getApplicationData().defaults.trans("sharing_options_desc")#</td>
		</tr>
		<tr>
			<td colspan="4">
				This folder is being shared: <cfif qry_folder.folder_shared EQ "T">Yes<cfelse>No</cfif><br>
				The original asset can be downloaded: <cfif qry_folder.share_dl_org EQ "T">Yes<cfelse>No</cfif><br>
				Assets have to be ordered: <cfif qry_folder.share_order EQ "T">Yes<cfelse>No</cfif>
			</td>
		</tr>
		<tr>
			<td colspan="4">#myFusebox.getApplicationData().defaults.trans("sharing_options_desc_2")#</td>
		</tr>
		<tr>
			<th></th>
			<th nowrap="nowrap">Downloadable</th>
			<th nowrap="nowrap">Orderable</th>
			<th nowrap="nowrap">Selected*</th>
		</tr>
		<cfif attributes.type EQ "img">
			<tr class="list">
				<td width="100%">#myFusebox.getApplicationData().defaults.trans("preview")# #ucase(thumbext)# (#myFusebox.getApplicationData().defaults.converttomb("#thumbsize#")# MB) (#thumbw#x#thumbh# pixel)</td>
				<td width="1%" align="center"><input type="checkbox" name="thumb_dl" id="thumb_dl" value="1" onclick="save_share('thumb','#attributes.file_id#','thumb','#attributes.type#','dl','#attributes.file_id#');" <cfif thumbdl>checked</cfif> /></td>
				<td width="1%" align="center"><input type="checkbox" name="thumb_or" id="thumb_or" value="1" onclick="save_share('thumb','#attributes.file_id#','thumb','#attributes.type#','or','#attributes.file_id#');" <cfif thumbor>checked</cfif> /></td>
				<td width="1%" align="center"><input type="radio" name="#attributes.file_id#_selected" id="#attributes.file_id#_selected" value="1" onclick="save_share('thumb','#attributes.file_id#','thumb','#attributes.type#','se','#attributes.file_id#');" <cfif thumbsel>checked</cfif> /></td>
			</tr>
		</cfif>
		<tr>
			<td width="100%">#myFusebox.getApplicationData().defaults.trans("original")#<cfif qry_detail.link_kind EQ ""> #ucase(orgext)# (#myFusebox.getApplicationData().defaults.converttomb("#orgsize#")# MB) <cfif attributes.type NEQ "aud" AND attributes.type NEQ "doc">(#orgw#x#orgh# pixel)</cfif></cfif><cfif qry_detail.link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif></td>
			<td width="1%" align="center"><input type="checkbox" name="org_dl" id="org_dl" value="1" onclick="save_share('org','#attributes.file_id#','org','#attributes.type#','dl','#attributes.file_id#');" <cfif orgdl>checked</cfif> /></td>
			<td align="center"><input type="checkbox" name="org_or" id="org_or" value="1" onclick="save_share('org','#attributes.file_id#','org','#attributes.type#','or','#attributes.file_id#');" <cfif orgor>checked</cfif> /></td>
			<td align="center"><input type="radio" name="#attributes.file_id#_selected" id="#attributes.file_id#_selected" value="1" onclick="save_share('org','#attributes.file_id#','org','#attributes.type#','se','#attributes.file_id#');" <cfif orgsel>checked</cfif> /></td>
		</tr>
		<cfif attributes.type NEQ "doc">
			<!--- List the converted formats --->
			<cfloop query="attributes.qry_related">
				<cfset dl = 0>
				<cfset order = 0>
				<cfset selected = 0>
				<cfif attributes.type EQ "img">
					<cfset theid = img_id>
					<cfset thegroupid = img_group>
					<cfset thef = img_extension>
					<cfset thesize = ilength>
					<cfset thew = orgwidth>
					<cfset theh = orgheight>
				<cfelseif attributes.type EQ "vid">
					<cfset theid = vid_id>
					<cfset thegroupid = vid_group>
					<cfset thef = vid_extension>
					<cfset thesize = vlength>
					<cfset thew = vid_height>
					<cfset theh = vid_width>
				<cfelseif attributes.type EQ "aud">
					<cfset theid = aud_id>
					<cfset thegroupid = aud_group>
					<cfset thef = aud_extension>
					<cfset thesize = aud_size>
					<cfset thew = 0>
					<cfset theh = 0>
				</cfif>
				<cfloop query="qry_share_options">
					<cfif asset_id_r EQ theid AND asset_dl>
						<cfset dl = 1>
					</cfif>
					<cfif asset_id_r EQ theid AND asset_order>
						<cfset order = 1>
					</cfif>
					<cfif asset_id_r EQ theid AND asset_selected>
						<cfset selected = 1>
					</cfif>
				</cfloop>
				<tr class="list">
					<td width="100%">#ucase(thef)# #myFusebox.getApplicationData().defaults.converttomb("#thesize#")# MB <cfif attributes.type NEQ "aud">(#thew#x#theh# pixel)</cfif></td>
					<td align="center"><input type="checkbox" name="#theid#_dl" id="#theid#_dl" value="1" onclick="save_share('#theid#','#theid#','#theid#','#attributes.type#','dl','#thegroupid#');" <cfif dl>checked</cfif> /></td>
					<td align="center"><input type="checkbox" name="#theid#_or" id="#theid#_or" value="1" onclick="save_share('#theid#','#theid#','#theid#','#attributes.type#','or','#thegroupid#');" <cfif order>checked</cfif> /></td>
					<td align="center"><input type="radio" name="#thegroupid#_selected" id="#thegroupid#_selected" value="1" onclick="save_share('#theid#','#theid#','#theid#','#attributes.type#','se','#thegroupid#');" <cfif selected>checked</cfif> /></td>
				</tr>
			</cfloop>
			
		</cfif>
               
		<cfif structKeyExists(attributes,'qry_additional_versions') AND attributes.qry_additional_versions.recordcount NEQ 0>
			<!--- LIST ADDITIONAL VERSIONS --->
			<cfloop query="attributes.qry_additional_versions">
				<cfset dl = 0>
				<cfset order = 0>
				<cfset selected = 0>
				<cfset theid = av_id>
				<cfset thegroupid = asset_id_r>
				<cfset thef = av_link_title>
				<cfset thew = thewidth>
				<cfset theh = theheight>
				<cfloop query="qry_share_options">
					<cfif asset_id_r EQ theid AND asset_dl>
						<cfset dl = 1>
					</cfif>
					<cfif asset_id_r EQ theid AND asset_order>
						<cfset order = 1>
					</cfif>
					<cfif asset_id_r EQ theid AND asset_selected>
						<cfset selected = 1>
					</cfif>
				</cfloop>
				<tr class="list"> 
					<td width="100%">#ucase(thef)# #myFusebox.getApplicationData().defaults.converttomb("#thesize#")# MB <cfif attributes.type NEQ "aud">(#thew#x#theh# pixel)</cfif></td>
					<td align="center"><input type="checkbox" name="#theid#_dl" id="#theid#_dl" value="1" onclick="save_share('#theid#','#theid#','av','#attributes.type#','dl','#thegroupid#');" <cfif dl>checked</cfif> /></td>
					<td align="center"><input type="checkbox" name="#theid#_or" id="#theid#_or" value="1" onclick="save_share('#theid#','#theid#','av','#attributes.type#','or','#thegroupid#');" <cfif order>checked</cfif> /></td>
					<td align="center"><input type="radio" name="#thegroupid#_selected" id="#thegroupid#_selected" value="1" onclick="save_share('#theid#','#theid#','av','#attributes.type#','se','#thegroupid#');" <cfif selected>checked</cfif> /></td>
				</tr>
			</cfloop>
		</cfif>
		<tr>
			<td colspan="4" align="right">* Selected is valid when you use a widget. The selected asset is then used for the larger preview or for the slideshow.</td>
		</tr>
	</table>
	<div id="save_status" style="padding:10px;color:green;display:none;"></div>
	<div id="save_status_hidden" style="display:none;"></div>

<script type="text/javascript">
	function save_share(theckb,fileid,asset_format,asset_type,action,groupid){
		// check checkbox
		var dl = $('##' + theckb + '_dl:checked').val();
		var or = $('##' + theckb + '_or:checked').val();
		var se = $('[name="' + groupid + '_selected"]:radio:checked').val();
		// Save
		loadcontent('save_status_hidden','#myself#c.share_options_save&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&id=' + fileid + '&format=' + asset_format + '&type=' + asset_type + '&dl=' + dl + '&order=' + or + '&selected=' + se);
		// Feedback
		$('##save_status').fadeTo("fast", 100);
		$('##save_status').css('display','');
		$('##save_status').html('We saved the change successfully!');
		$('##save_status').fadeTo(1000, 0);
	}
</script>
</cfif>
</cfoutput>