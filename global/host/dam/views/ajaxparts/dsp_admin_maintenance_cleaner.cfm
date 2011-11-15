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
<script>
// Check all checkboxes
function CheckAll(myform) {
	for (var i = 0; i < document.forms[myform].elements.length; i++) {
		if (document.forms[myform].elements[i].type == 'checkbox'){
		document.forms[myform].elements[i].checked =! (document.forms[myform].elements[i].checked);
		}
	}
}
function show_confirm(theform,thetype) {
var r=confirm("Do you really want to remove the selected records?");
if (r==true)
	{
		delsel(theform,thetype)
	}
else
	{
		return false;
	}
}
// Selected to Basket
function delsel(theform,thetype){
	// Get the checked values (file id's)
	var fileids = '';
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
       if ((document.forms[theform].elements[i].name.indexOf('id') > -1)) {
           if (document.forms[theform].elements[i].checked) {
				fileids += document.forms[theform].elements[i].value + ',';
           }
      	}
   	}
   	// Load page again
	window.location.href='<cfoutput>#myself#</cfoutput>c.admin_cleaner_delete&id=' + fileids + '&thetype=' + thetype;
   	//loadcontent('thedropbasket','<cfoutput>#myself#</cfoutput>c.basket_put&file_id=' + fileids + '&thetype=' + filetypes);
}
function show_confirm_one(theid,thetype) {
var r=confirm("Do you really want to remove this record?");
if (r==true)
	{
		window.location.href='<cfoutput>#myself#</cfoutput>c.admin_cleaner_delete&id=' + theid + '&thetype=' + thetype;
	}
else
	{
		return false;
	}
}
</script>
<style>
	html, body {
		height: 100%;
		width: 100%;
	}
	body {
	    background-color: #FFFFFF;
	    font-size:12px;
	    font-family: 'Helvetica Neue',Helvetica,Arial,"Nimbus Sans L",sans-serif;
		margin: 0;
		padding: 10px;
	}
	table{
		font-family: 'Helvetica Neue',Helvetica,Arial,"Nimbus Sans L",sans-serif;
		font-size: 12px;
		border: 1px solid #BEBEBE;
		padding: 0px;
		margin: 0px;
	}
	th{
		background: #E2E2E2;
		font-weight: bold;
		padding: 5px;
	}
	td{
		padding: 3px;
	}
</style>
<cfoutput>
	<h2>1. Records that are not assigned to a folder</h2>
	<p>Check here for records that are not assigned to any folder. This usually means they are left over records or so called "zombie" records that can be removed.</p>
	<!--- Files --->
	<cfif qry_files.recordcount EQ 0>
		<span style="color:green;">There are no document records that are not assigned to a folder. This is a good thing!</span><br />
	<cfelse>
		<!--- Set variables for the include --->
		<cfset thetitle = "Document">
		<cfset theform = "doc" />
		<cfset theqry = qry_files>
		<cfinclude template="inc_admin_asset_tables.cfm" />
	</cfif>
	<!--- Audios --->
	<cfif qry_audios.recordcount EQ 0>
		<span style="color:green;">There are no audio records that are not assigned to a folder. This is a good thing!</span><br />
	<cfelse>
		<!--- Set variables for the include --->
		<cfset thetitle = "Audios">
		<cfset theform = "aud" />
		<cfset theqry = qry_audios>
		<cfinclude template="inc_admin_asset_tables.cfm" />
	</cfif>
	<!--- Videos --->
	<cfif qry_videos.recordcount EQ 0>
		<span style="color:green;">There are no video records that are not assigned to a folder. This is a good thing!</span><br />
	<cfelse>
		<!--- Set variables for the include --->
		<cfset thetitle = "Videos">
		<cfset theform = "vid" />
		<cfset theqry = qry_videos>
		<cfinclude template="inc_admin_asset_tables.cfm" />
	</cfif>
	<!--- Images --->
	<cfif qry_images.recordcount EQ 0>
		<span style="color:green;">There are no image records that are not assigned to a folder. This is a good thing!</span><br />
	<cfelse>
		<!--- Set variables for the include --->
		<cfset thetitle = "Images">
		<cfset theform = "img" />
		<cfset theqry = qry_images>
		<cfinclude template="inc_admin_asset_tables.cfm" />
	</cfif>
	<h2>2. Check records against the file system</h2>
	<p>Here we will check your records against the assets on your filesystem.</p>
	<p><a href="##" onclick="window.open('#myself#c.admin_cleaner_check_asset&thetype=img&v=#createuuid()#', 'windocleaner', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=800,height=600');">Check Image records</a></p>
	<p><a href="##" onclick="window.open('#myself#c.admin_cleaner_check_asset&thetype=vid&v=#createuuid()#', 'windocleaner', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=800,height=600');">Check Video records</a></p>
	<p><a href="##" onclick="window.open('#myself#c.admin_cleaner_check_asset&thetype=doc&v=#createuuid()#', 'windocleaner', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=800,height=600');">Check Document records</a></p>
	<p><a href="##" onclick="window.open('#myself#c.admin_cleaner_check_asset&thetype=aud&v=#createuuid()#', 'windocleaner', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=800,height=600');">Check Audio records</a></p>
	
</cfoutput>