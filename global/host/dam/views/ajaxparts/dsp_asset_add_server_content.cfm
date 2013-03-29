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
<cfdirectory action="list" directory="#attributes.folderpath#" name="thecontent" sort="name ASC">
<cfquery name="fc" dbtype="query">SELECT * FROM thecontent WHERE type = 'File' AND attributes != 'H' AND name NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value=".svn,.DS_Store,.git">)</cfquery>
<cfoutput>
<div id="uploadstatus" style="background-color:##FFFFE0;display:none;"></div>
<form name="assetserverform" id="assetserverform" method="post" action="#self#">
<input type="hidden" name="#theaction#" value="#xfa.submitassetserver#">
<!--- <input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#"> --->
<input type="hidden" name="folder_id" value="#attributes.folder_id#">
<input type="hidden" name="thepath" value="#thisPath#">
<input type="hidden" name="folderpath" value="#attributes.folderpath#">
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="tablepanel">
	<tr>
		<th colspan="3">#myFusebox.getApplicationData().defaults.trans("content_of_folder")#: #listlast("#attributes.folderpath#","/\")#</th>
	</tr>
	<tr>
		<td colspan="3"><input type="checkbox" id="checkall" onclick="selectallserver(this.checked);"> Check all</td>
	</tr>
	<cfloop query="fc">
		<tr>
			<td width="1%" class="td2" nowrap="true"><input type="checkbox" class="thefiles" name="thefile" value="#name#" onClick="enablesubserver('assetserverform');"></td>
			<td width="100%" class="td2" nowrap="true" style="padding-left:0px;">#name#</td>
			<cfif currentRow EQ 1>
			<td width="1%" class="td2" nowrap="true"><input type="submit" name="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("add_file")#" class="button" disabled></td>
			</cfif>
		</tr>
	</cfloop>
</table>
<br>
<div>
	<div style="float:left;">
		<input type="checkbox" name="zip_extract" value="1" checked="checked"> #myFusebox.getApplicationData().defaults.trans("header_zip_desc")#
	</div>
	<!--- Load upload templates here --->
	<cfif qry_templates.recordcount NEQ 0>
		<div style="float:right;">
			<select name="upl_template">
				<option value="0" selected="selected">Choose Rendition Template</option>
				<option value="0">---</option>
				<cfloop query="qry_templates">
					<option value="#upl_temp_id#">#upl_name#</option>
				</cfloop>
			</select>
		</div>
	</cfif>
</div>
<!---

<table border="0" cellpadding="0" cellspacing="0" width="100%" class="tablepanel">
	<tr>
		<td class="td2"><input type="checkbox" name="zip_extract" value="1" checked> #myFusebox.getApplicationData().defaults.trans("header_zip_desc")#</td>
	</tr>
	<!---
<tr>
		<th>#myFusebox.getApplicationData().defaults.trans("header_thumbnail_size")#</th>
	</tr>
	<tr>
		<td class="td2">#myFusebox.getApplicationData().defaults.trans("header_thumbnail_size_desc")#</td>
	</tr>
	<tr>
		<td class="td2">#myFusebox.getApplicationData().defaults.trans("width")# <input type="text" name="img_thumb_width" size="4" maxlength="3" value="#settings_image.set2_img_thumb_width#"> #myFusebox.getApplicationData().defaults.trans("heigth")# <input type="text" name="img_thumb_heigth" size="4" maxlength="3" value="#settings_image.set2_img_thumb_heigth#"></td>
	</tr>
--->
	<!--- <tr>
		<th>#myFusebox.getApplicationData().defaults.trans("header_video_preview_size")#</th>
	</tr>
	<tr>
		<td class="td2">#myFusebox.getApplicationData().defaults.trans("header_video_preview_size_desc")#</td>
	</tr>
	<tr>
		<td class="td2">#myFusebox.getApplicationData().defaults.trans("width")# <input type="text" name="vid_preview_width" size="4" maxlength="3" value="#settings_video.set2_vid_preview_width#" onchange="aspectheight(this,'vid_preview_heigth','assetserverform');"> #myFusebox.getApplicationData().defaults.trans("heigth")# <input type="text" name="vid_preview_heigth" size="4" maxlength="3" value="#settings_video.set2_vid_preview_heigth#" onchange="aspectwidth(this,'vid_preview_width','assetserverform');"></td>
	</tr> --->
</table>
--->
</form>

<!--- JS to submit form here --->
<script language="javascript">
	$("##assetserverform").submit(function(e) {
		var url = formaction("assetserverform");
		var items = formserialize("assetserverform");
		// Show loading message in upload window
		$("##uploadstatus").css("display","");
		$("##uploadstatus").html('<div style="padding:10px"><img src="#dynpath#/global/host/dam/images/loading.gif" border="0" width="16" height="16"><br><br>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("upload_wait_message"))#</div>');
		// Submit Form
        $.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: function(){
		   		setTimeout(function() {
			    	calledwithdelayserver();
				}, 3000)
		   	}
		});
		return false;
	});
	function calledwithdelayserver(){
   		$("##uploadstatus").html('<div style="padding:10px;font-weight:bold;color:##900;">#JSStringFormat(myFusebox.getApplicationData().defaults.trans("upload_success_email"))#</div>');
   		$("##uploadstatus").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
   		<cfif pl_return.cfc.pl.loadform.active>
   			// This is for the metaform plugin
			// close window
			$('##thewindowcontent1').dialog('close');
			$('##thewindowcontent2').dialog('close');
			// load metaform
			$('##rightside').load('#myself#c.plugin_direct&comp=metaform.cfc.settings&func=loadForm');
   		</cfif>
	}
	function selectallserver(status){
		$(".thefiles").each( function() {
			$(this).attr("checked",status);
		});
		enablesubserver('assetserverform');
	};	
</script>

</cfoutput>