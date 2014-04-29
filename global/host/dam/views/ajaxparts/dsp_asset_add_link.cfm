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
		#myFusebox.getApplicationData().defaults.trans("link_desc")#<br><br>
		<cfinclude template="dsp_host_upgrade.cfm">
	<cfelse>
		<form name="formassetlink" id="formassetlink" action="#self#" method="post" onsubmit="addlink();return false;">
		<input type="hidden" name="#theaction#" value="#xfa.addlink#">
		<input type="hidden" name="folder_id" value="#attributes.folder_id#">
		<table border="0" cellpadding="0" cellspacing="0" width="600">
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("link_desc")#</td>
			</tr>
			<tr>
				<td colspan="2" style="padding-top:15px;"><hr></td>
			</tr>
			<tr>
				<td nowrap="true" style="padding-top:10px;"><strong>#myFusebox.getApplicationData().defaults.trans("link_asset_store")#</strong></td>
			</tr>
			<!--- Hide UPC settings if storage is not local --->
			 <cfif !application.razuna.storage eq 'local'>
			 	<cfset csshide= "style='display:none'">
			 <cfelse> 
			 	<cfset csshide= "">
			</cfif>
			<tr>
				<td><input name="link_kind" type="radio" value="url" checked="true" onclick="togglefileinput(1)"> On public URL <input name="link_kind" type="radio" value="urlvideo" onclick="togglefileinput(1)"> Video with embedded player <cfif !application.razuna.isp>
				<span  #csshide#><input name="link_kind" type="radio" value="lan" onclick="togglefileinput(0)"> Available on my local network</span>
				</cfif></td>
			</tr>
			<tr>
				<td width="1%" nowrap="true" style="padding-top:7px;"><strong>#myFusebox.getApplicationData().defaults.trans("link_path_url")#</strong></td>
			</tr>
			<tr>
				<td width="100%"><textarea name="link_path_url" style="width:550px;height:35px;"></textarea></td>
			</tr>
			<!--- <tr>
				<td nowrap="true" style="padding-top:7px;"><strong>#myFusebox.getApplicationData().defaults.trans("link_download")#</strong><br /><i>(#myFusebox.getApplicationData().defaults.trans("link_download_desc")#)</i></td>
			</tr>
			<tr>
				<td><input type="radio" name="link_download" value="no" checked="true">#myFusebox.getApplicationData().defaults.trans("no")# <input type="radio" name="link_download" value="yes">#myFusebox.getApplicationData().defaults.trans("yes")#</td>
			</tr> --->
			<tr>
				<td width="1%" nowrap="true" style="padding-top:7px;"><span id="filelabel"><strong>#myFusebox.getApplicationData().defaults.trans("file_name")#</strong></span></td>
			</tr>
			<tr>
				<td width="100%"><input name="link_file_name" id="link_file_name" type="text" style="width:550px;"></td>
			</tr>
			<tr>
				<td colspan="2" style="padding-top:20px;"><div style="float:left;"><input type="button" name="cancel" value="#myFusebox.getApplicationData().defaults.trans("back_to_folder")#" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#attributes.folder_id#');return false;" class="button"></div><div style="float:right;"><input type="button" name="submit" value="#myFusebox.getApplicationData().defaults.trans("header_add_asset")#" class="button" onclick="addlink();"></div></td>
			</tr>
		</table>
		<div id="addlinkstatus" style="display:none;"></div>
		</form>
		<!--- JS for form --->
		<script language="javascript">
			function togglefileinput(display)
			{
				if(display==0)
				{
					$("##link_file_name").css("display","none");
					$("##filelabel").css("display","none");
				}
				else
				{
					$("##link_file_name").css("display","");
					$("##filelabel").css("display","");
				}

			}
			function addlink(){
				$("##addlinkstatus").css("display","");
				loadinggif('addlinkstatus');
				$("##addlinkstatus").fadeTo("fast", 100);
				var url = formaction("formassetlink");
				var items = formserialize("formassetlink");
				// Submit Form
		       	$.ajax({
					type: "POST",
					url: url,
				   	data: items,
				   	success: function(result){
						if($.trim(result) == "file_not_found_error"){
							$("##addlinkstatus").css({'color':'red','font-weight':'bold','padding-top':'10px'});
							$("##addlinkstatus").html("#myFusebox.getApplicationData().defaults.trans('file_not_found_error')#");
						}else{
							// Update Text
							$("##addlinkstatus").css({'color':'green','font-weight':'bold','padding-top':'10px'});
							$("##addlinkstatus").html("#myFusebox.getApplicationData().defaults.trans("link_added")#");
						}
						$("##addlinkstatus").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
				   	}
				});
		        return false; 
			}
		</script>
	</cfif>
</cfoutput>