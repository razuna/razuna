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
<cfparam name="attributes.label_id" default="" />
<cfoutput>	
<div>
	<form name="form_download_folder" id="form_download_folder" method="post" action="#self#" target="_blank">
	<input type="hidden" name="#theaction#" value="c.download_folder_do">
	<input type="hidden" name="folder_id" value="#attributes.folder_id#">
	<input type="hidden" name="label_id" value="#attributes.label_id#">
	<!--- Desc --->
	<p>#myFusebox.getApplicationData().defaults.trans("header_download_folder_desc")#</p>
	<p><hr /></p>
	<div>
		<div style="float:left;font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("download_folder_what")#</div>
		<div style="float:left;">
			<input type="checkbox" name="download_thumbnails" value="true" checked="checked" /> Thumbnails
			<input type="checkbox" name="download_originals" value="true" checked="checked" /> #myFusebox.getApplicationData().defaults.trans("originals")#
			<input type="checkbox" name="download_renditions" value="true" /> Renditions
			<!--- <input type="checkbox" name="download_sunfolders" value="true" /> Assets in sub-folders --->
		</div>
	</div>
	<div style="clear:both;padding-bottom:20px;"></div>
	<div style="float:right;padding:10px;"><input type="submit" name="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("header_download_folder")#" class="button"></div>
	</form>
</div>
<script type="text/javascript">
$("##form_download_folder").submit(function(e){
	var checked = $("##form_download_folder input:checked").length > 0;
    if (!checked){
        alert("Please check at least one checkbox");
        return false;
    }
})
</script>
</cfoutput>