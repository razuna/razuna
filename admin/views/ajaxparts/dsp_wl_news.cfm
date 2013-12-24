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
	<p>#myFusebox.getApplicationData().defaults.trans("header_wl_news")#</p>
	<hr>
	<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_news_rss")#</strong><br />
	#myFusebox.getApplicationData().defaults.trans("header_wl_news_rss_desc")#<br />
	<input type="text" style="width:600px" name="wl_news_rss" value="#attributes.rss#" /> <input type="submit" name="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("save")#"><br />
	<div id="wlfeedback3" style="display:none;font-weight:bold;color:green;padding-bottom:15px;"></div>
	<hr>
	<strong>#myFusebox.getApplicationData().defaults.trans("header_wl_news_section")#</strong><br />
	#myFusebox.getApplicationData().defaults.trans("header_wl_news_section_desc")#<br />
	<p><input type="button" name="createnew" value="#myFusebox.getApplicationData().defaults.trans("header_wl_news_new")#" onclick="showwindow('#myself#c.wl_news_edit&add=true','News record',750,1);"></p>
	<!--- List of news --->
	<table border="0" width="700px">
		<tr>
			<th>Title</th>
			<th>Date (US format)</th>
			<th></th>
		</tr>
		<!--- Loop --->
		<cfloop query="qry_news">
			<tr>
				<td><a href="##" onclick="showwindow('#myself#c.wl_news_edit&news_id=#news_id#','News record',750,1);">#news_title#</a></td>
				<td>#news_date#</td>
				<td><a href="##" onclick="nDelete('#news_id#');return false;">Delete</a></td>
			</tr>
		</cfloop>
	</table>
	<div id="news-confirm" title="Really delete this news entry?" style="display:none;">
		<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 60px 0;"></span>This news entry will be removed. This action can not be un-done. <br /><br />Are you sure that you want to delete this record now?</p>
	</div>
	<script type="text/javascript">
		// Delete Workflow
		function nDelete(nid){
			
			// http://stackoverflow.com/questions/15763909/jquery-ui-dialog-check-if-exists-by-instance-method
			if ($("##news-confirm").hasClass('ui-dialog-content')) {
				$( "##news-confirm" ).dialog( "destroy" );
			}

			$( "##news-confirm" ).dialog({
				resizable: false,
				height: 200,
				modal: true,
				buttons: {
					"Delete record": function() {
						// Call action to delete this workflow
						$('##loaddummy').load('#myself#c.wl_news_remove&news_id=' + nid);
						// Refresh list in the back
						loadcontent('wl_news','#myself#c.wl_news');
						// Close this window
						$( this ).dialog( "close" );
					},
					Cancel: function() {
						$( this ).dialog( "close" );
					}
				}
			});
		};
	</script>
</cfoutput>