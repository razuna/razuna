<!---
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
<cfcontent reset="true">
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
<cfoutput>
<head>
<link rel="stylesheet" href="#dynpath#/global/host/dam/views/layouts/main.css" type="text/css" />
<link rel="stylesheet" href="#dynpath#/global/js/chosen/chosen.css" type="text/css" />
<script  type="text/javascript" src="#dynpath#/global/js/jquery-1.10.2.min.js"></script>
<script  type="text/javascript" src="#dynpath#/global/js/chosen/chosen.jquery.min.js"></script>
<style type="text/css">
.chzn-container .chzn-drop .chzn-results {
	overflow: auto;
	max-height: 70px;
}
</style>
<head>
<body>
	<form name="form_folderthumb#attributes.folder_id#" id="form_folderthumb#attributes.folder_id#" action="#self#" method="post" enctype="multipart/form-data">
	<input type="hidden" name="#theaction#" value="#xfa.submitfolderform#">
	<input type="hidden" name="thepathup" value="#ExpandPath("../../")#">
	<input type="hidden" name="theid" value="#attributes.theid#">
	<input type="hidden" name="folderId" value="#attributes.folder_id#">
	<input type="hidden" name="dyn_path" value="#dynpath#">
	<input type="hidden" name="img_ext" value="#qry_files.thumb_extension#">
	<input type="hidden" name="uploadnow" value="T">
	<div id="folder" style="width:695px;padding-bottom:60px;">
		<div id="folder_thumb#attributes.folder_id#-#attributes.isdetail#">
			<table border="0" cellpadding="0" cellspacing="0">
				<tr>
					<th>#myFusebox.getApplicationData().defaults.trans("folder_thumbnail_header")#</th>
				</tr>
				<tr>
					<td>#myFusebox.getApplicationData().defaults.trans("folder_thumbnail_desc")#</td>
				</tr>
				<tr>
					<td style="padding-top:15px;">
						<div id="folderThumb_load" class="theimg">
							<cfif directoryexists("#ExpandPath("../..")#global/host/folderthumbnail/#session.hostid#/#attributes.folder_id#")>
								<cfdirectory name="myDir" action="list" directory="#ExpandPath("../../")#global/host/folderthumbnail/#session.hostid#/#attributes.folder_id#" type="file">
								<cfif myDir.RecordCount>
									<img src="#dynpath#/global/host/folderthumbnail/#session.hostid#/#attributes.folder_id#/#myDir.name#?#createuuid()#" border="0" height="100px" align="left">
									<a href="#myself#c.folder_thumbnail_reset&folder_id=#attributes.folder_id#" style="padding-left:15px;">Reset to default</a>
									<br />
								<cfelse>
									<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0" height="100px"><br />
								</cfif>
							<cfelse>
								<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0" height="100px"><br />
							</cfif>
						</div>
					</td>
				</tr>
				<tr>
					<th style="padding-top:15px;">Upload your thumbnail or ...</th>
				</tr>
				<tr>
					<td><input type="file" name="thumb_folder_file" id="thumb_folder_file" size="50"></td>
				</tr>
				<tr>
					<th style="padding-top:15px;">...choose from existing images in this folder</th>
				</tr>
				<!--- Thumbnail Combo --->
				<tr>
					<td width="100%" nowrap="true" colspan="2">
						<div style="float:left;">
							<select data-placeholder="Choose a thumbnail" class="chzn-select" style="width:400px;" id="thumb_folder" name="thumb_folder">
								<option value=""></option>
								<cfloop query="qry_files" >
									<cfif application.razuna.storage EQ 'local'>
										<option value="#dynpath#/assets/#session.hostid#/#path_to_asset#/thumb_#img_id#.#thumb_extension#">#img_filename#</option>
									<cfelse>
										<option value="#cloud_url#">#img_filename#</option>
									</cfif>
								</cfloop>
							</select>
						</div>
						<div style="float:left;padding-left:10px;"><input type="submit" name="submitapply" id="foldersubmitbutton" value="Apply" class="button"></div>
					</td>
				</tr>
				<tr>
					<td><div id="ExistingThumb_load" class="theimg"></div></td>
				</tr>
			</table>
		</div>	
		<div style="clear:both;"></div>
		<div style="float:left;padding-top:10px;padding-bottom:10px;">
			<div id="updatetextthumb" style="float:right;color:green;padding-right:10px;padding-top:4px;font-weight:bold;">
				<cfif structkeyexists(form,"fieldnames")> &nbsp;Image applied successfully.</cfif>
			</div>
		</div>
	</div>
	</form>
	<!--- JS --->
	<script language="JavaScript" type="text/javascript">
		// Activate Chosen
		$(".chzn-select").chosen({search_contains: true});
		//set width
		$('##thumb_folder_chosen').width(400);
		// Show image
		$('##thumb_folder').change(function(){
			var image=$('##thumb_folder').val();
			if(image != ''){
				$('##ExistingThumb_load').html('<img src="'+image+'" height="100" border="0">');
			}
		});
		// Upload
		$('##thumb_folder_file').change(function() { 
	        // select the form and submit
	        $('##form_folderthumb#attributes.folder_id#').submit();
	    });
	</script>
</cfoutput>
</body>
</html>