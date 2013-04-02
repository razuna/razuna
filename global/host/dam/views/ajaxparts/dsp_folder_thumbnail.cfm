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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" >
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
<cfoutput>
<head>
<link rel="stylesheet" href="#dynpath#/global/host/dam/views/layouts/main.css" type="text/css" />
<link rel="stylesheet" href="#dynpath#/global/js/chosen/chosen.css" type="text/css" />
<script  type="text/javascript" src="#dynpath#/global/js/jquery-1.7.2.min.js"></script>
<script  type="text/javascript" src="#dynpath#/global/js/chosen/chosen.jquery.min.js"></script>
<head>
<body>
	<cfform name="form_folderthumb#attributes.theid#" action="#self#" method="post" enctype="multipart/form-data" id="form_folderthumb#attributes.theid#">
	<input type="hidden" name="#theaction#" value="#xfa.submitfolderform#">
	<input type="hidden" name="thepathup" value="#ExpandPath("../../")#">
	<input type="hidden" name="theid" value="#attributes.theid#">
	<input type="hidden" name="folderId" value="#attributes.folder_id#">
	<input type="hidden" name="uploadnow" value="T">
	<div id="folder" style="width:695px;padding-bottom:60px;">
		<div id="folder_thumb#attributes.theid#-#attributes.isdetail#">
			<table border="0" cellpadding="0" cellspacing="0" class="grid">
				
				<tr>
					<td>
						<div id="folderThumb_load"  class="theimg">
							<img src="#dynpath#/global/host/floderthumbnail/#session.hostid#/#attributes.folder_id#.jpg" border="0" height="100px;" width="100px;"><br />
						</div>
					</td>
					
				</tr>
				<tr>
					<td><cfinput type="file" name="thumb_folder_file" id="thumb_folder_file" size="50"></td>
				</tr>	
				<!--- Thumbnail Combo --->
				<tr>
					<td width="100%" nowrap="true" colspan="2">
						<select data-placeholder="Choose a thumnail" class="chzn-select" style="width:400px;" id="thumb_folder" name="thumb_folder">
							<option value=""></option>
							<cfloop query="qry_files" >
							<option value="#img_id#/#img_filename#">#img_filename#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2" class="list"></td>
				</tr>
				
			</table>
		</div>	
		<div style="clear:both;"></div>
		<div style="float:left;padding-top:10px;padding-bottom:10px;">
			<input type="submit" name="submit" id="foldersubmitbutton" value="#myFusebox.getApplicationData().defaults.trans("upload")#" class="button">
			<div id="updatetextthumb" style="float:right;color:green;padding-right:10px;padding-top:4px;font-weight:bold;">
				<cfif structkeyexists(form,"fieldnames")> &nbsp;Image uploaded successfully. Please click on refresh.</cfif>
			</div>
		</div>
	</div>
	
	</cfform>
</body>
	<!--- JS --->
	
	<script language="JavaScript" type="text/javascript">
		// Activate Chosen
		$(".chzn-select").chosen();
		
		//$('##folderThumb_load').load('#myself#ajax.prefs_floderThumb&folder_id=#attributes.folder_id#');
		
		$('##thumb_folder').change(function(){
			image=$('##thumb_folder').val();
			$('##folderThumb_load').html('<img src="#dynpath#/assets/#session.hostid#/#attributes.folder_id#/img/'+image+'" height="100px;" width="100px;">');
		});
		
		
	</script>
</cfoutput>
<html>