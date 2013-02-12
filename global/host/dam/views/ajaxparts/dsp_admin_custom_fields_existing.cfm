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
<style>
	.actionbox {
		border: 1px solid #D3D3D3;
		padding: 10px;
		margin: 10px;
		background: #E6E6E6;
		border-radius: 10px;
		-webkit-border-radius: 10px;
	    -moz-border-radius: 10px;
	    cursor: move;
	}
	.myplace { 
		height: 50px; 
		line-height:50px; 
		border: 3px dotted grey;
		padding: 10px;
		margin: 10px;
		border-radius: 10px;
		-webkit-border-radius: 10px;
	    -moz-border-radius: 10px;
	}
</style>
<cfif qry_fields.recordcount NEQ 0>
	<cfset sortorder = "">
	<cfoutput>
		<div id="thefields">
			<cfoutput query="qry_fields" group="cf_id">
				<div id="#cf_id#" class="actionbox">
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
						<tr>
							<td nowrap="true"><img src="#dynpath#/global/host/dam/images/arrow-out.png" border="0"></td>
							<td width="100%"><a href="##" onclick="showwindow('#myself#c.custom_fields_detail&cf_id=#cf_id#','#cf_text#',680,1);return false">#cf_text#</a><br /><em>(ID: #cf_id#)</em></td>
							<td width="1%" nowrap="true">#cf_type#</td>
							<td width="1%" nowrap="true">
								<cfif cf_show EQ "vid">
									#myFusebox.getApplicationData().defaults.trans("search_for_videos")#
								<cfelseif cf_show EQ "img">
									#myFusebox.getApplicationData().defaults.trans("search_for_images")#
								<cfelseif cf_show EQ "aud">
									#myFusebox.getApplicationData().defaults.trans("search_for_audios")#
								<cfelseif cf_show EQ "doc">
									#myFusebox.getApplicationData().defaults.trans("search_for_documents")#
								<cfelseif cf_show EQ "all">
									#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#
								<cfelseif cf_show EQ "users">
									Users
								</cfif>
							</td>
							<td width="1%" nowrap="true" align="center"><cfif cf_enabled EQ "T"><img src="#dynpath#/global/host/dam/images/checked.png" width="16" height="16" border="0"></cfif></td>
							<td width="1%" nowrap="true" align="center"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=custom_fields&id=#cf_id#&loaddiv=thefields&order=#cf_order#','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
						</tr>
					</table>
				</div>
				<!--- Set order --->
				<cfset sortorder = sortorder & "," & cf_id>
			</cfoutput>
		</div>
	</cfoutput>
	<script type="text/javascript">
		// Make theactions sortable
		$('#thefields').sortable({
			placeholder: "myplace",
			distance: 15,
			opacity: 0.6,
			scroll: true,
			stop: function( event, ui ) { 
				var s = $("#thefields").sortable('toArray').toString();
				$('#div_forall').load('index.cfm?fa=c.custom_fields_save_order', { theorderlist: s });
			}
		});
	</script>
</cfif>
