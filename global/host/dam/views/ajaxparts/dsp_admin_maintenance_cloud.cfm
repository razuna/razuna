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

	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th>Re-create URL's for ALL assets</th>
		</tr>
		<tr class="list">
			<td>
			Each asset has a signed URL that is being generated during uploading to Razuna. URL's have a expiration date of 10 years. If you need to re-create the URL's for ALL assets then please use the link below. <br /><br /><strong>Caution: This will create a NEW URL for each asset and is usually NOT needed! Only execute this if you know what you are doing or have been instructed to do so!</strong><br /><br />
			<a href="##" onclick="dourls();">Re-create URL's</a>
			<br /><br />
			</td>
		</tr>
	</table>
	
	<div id="dummy_maintenance_cloud"></div>
	<!--- Load Progress --->
	<script type="text/javascript">
		// Do Cleaner
		function dourls(){
			window.open('#myself#c.admin_maintenance_cloud_do&v=#createuuid()#', 'urlsdo', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=800,height=600');
		};
	</script>
</cfoutput>