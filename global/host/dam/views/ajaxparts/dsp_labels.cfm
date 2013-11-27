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
	<!--- Folders --->
	<!--- <div style="padding-left:10px;font-weight:bold;float:left;">Labels</div> --->
	<div style="width:60px;float:right;left:190px;position:absolute;top:3px;">
		<div style="float:left;"><a href="##" onclick="$('##labeltools').toggle();" style="text-decoration:none;" class="ddicon">Manage</a></div>
		<div style="float:right;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" onclick="$('##labeltools').toggle();" class="ddicon"></div>
		<div id="labeltools" class="ddselection_header" style="top:18px;width:250px;z-index:6;">
			<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
				<p>Add Label</p>
				<p><input type="text" name="label_text" id="label_text" style="width:120px;"> <input type="button" value="#myFusebox.getApplicationData().defaults.trans("labels_add")#" class="button" onclick="addlabel();"></p>
				<p>Nest label under:<br />
					<select name="sublabelof" id="sublabelof" style="width:240px;">
					<option value="0" selected="selected">Please select a parent...</option>
					<cfloop query="list_labels_dropdown">
						<option value="#label_id#">#label_path#</option>
					</cfloop>
				</select></p>
				<p><hr></p>
			</cfif>
			<p><a href="##" onclick="loadcontent('explorer','#myself#c.labels_list');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_refresh_tree")#">#myFusebox.getApplicationData().defaults.trans("reload")#</a></p>
		</div>
	</div>
	<div style="clear:both;"></div>
	<div id="labtree" style="width:200;height:200;float:left;">
	</div>
	<div style="clear:both;"></div>

<script language="javascript" type="text/javascript">
	// Load Collections
	$(function () { 
		$("##labtree").tree({
			plugins : {
				cookie : { prefix : "cookielabtree_" }
			},
			types : {
				"default" : {
					deletable : false,
					renameable : false,
					draggable : false,
					icon : { 
						image : "#dynpath#/global/host/dam/images/tag_16.png"
					}
				}
			},
			data : { 
				async : true,
				opts : {
					url : "#myself#c.labels_tree"
				}
			}
		});
	});
	// Add Label
	function addlabel(){
		//check label for first char and letters
		if(!isValidLabel('label_text')){
			alert('Please use first charactor as letters or numbers.');
			return false;
		}
		
		// Get value
		var thelab = $("##label_text").val().trim();
		var theparent = $("##sublabelof option:selected").val();
		// Submit
		if (thelab != "") {
			$('##explorer').load('#myself#c.labels_add', {label_id:0, label_text: thelab, label_parent: theparent});
		}
		else {
			return false;
		}
	}
</script>
</cfoutput>
	
