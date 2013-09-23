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
<cfset tempid = createuuid('')>
<cfoutput>	
	<div>
		<form name="form_meta_imp" id="form_meta_imp" method="post" action="#self#" target="_blank">
		<input type="hidden" name="#theaction#" value="c.users_import_do">
		<input type="hidden" name="tempid" value="#tempid#">
		<!--- Desc --->
		<p>Quickly import users into your Razuna account.</p>
		<p><hr /></p>
		<div>
			<div style="float:left;width:150px;font-weight:bold;">File Format</div>
			<div style="float:left;">
				<input type="radio" name="file_format" value="csv" checked="checked"> CSV <input type="radio" name="file_format" value="xlsx"> XLSx <input type="radio" name="file_format" value="xls"> XLS
			</div>
			<div style="clear:both;padding-bottom:10px;"></div>
			<!--- Upload file --->
			<div style="float:left;width:150px;font-weight:bold;padding-top:7px;">Upload File</div>
			<div style="float:left;"><iframe src="#myself#ajax.users_import_upload&tempid=#tempid#" frameborder="false" scrolling="false" style="border:0px;width:300px;height:50px;" id="usersupload"></iframe></div>
		</div>
		<div style="clear:both;padding-bottom:10px;"></div>
			<!--- Loading Bars --->
		<div style="float:left;padding:10px;color:green;font-weight:bold;display:none;" id="importstatus"></div>
		<div style="float:right;padding:10px;"><input type="submit" name="submitbutton" value="Import users" class="button"></div>
		<cfif structKeyExists(attributes,"ad_server_name") AND attributes.ad_server_name NEQ "" AND structKeyExists(attributes,"ad_server_username") AND attributes.ad_server_username NEQ "" AND structKeyExists(attributes,"ad_server_password") AND attributes.ad_server_password NEQ "" AND structKeyExists(attributes,"ad_server_start") AND attributes.ad_server_start NEQ "">
			<div style="float:right;padding:10px;"><button onclick="showwindow('#myself#c.ad_server_users_list','AD Server Users List',600,1);return false;" class="button">#myFusebox.getApplicationData().defaults.trans("Import_AD_Users")#</button></div>
		</cfif>
		</form>
	</div>
</cfoutput>