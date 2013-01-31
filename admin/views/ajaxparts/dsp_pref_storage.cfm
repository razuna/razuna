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
	<table width="700" border="0" cellspacing="0" cellpadding="0" class="grid">
		<!--- Could Storage header --->
		<!--- <tr>
			<th class="textbold" colspan="2">Cloud Storage #defaultsObj.trans("settings")#</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("storage_desc")#</td>
		</tr> --->
		<!--- Nirvanix --->
		<cfif application.razuna.storage EQ "nirvanix">
			<tr>
				<th class="textbold" colspan="2">Nirvanix #defaultsObj.trans("settings")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("nirvanix_desc")#</td>
			</tr>
			<tr>
				<td nowrap="true" valign="top">Child Account Name</td>
				<td><input type="text" name="set2_nirvanix_name" id="set2_nirvanix_name" size="40" value="#prefs.set2_nirvanix_name#" /></td>
			</tr>
			<tr>
				<td nowrap="true" valign="top">Child Account Password</td>
				<td><input type="password" name="set2_nirvanix_pass" id="set2_nirvanix_pass" size="40" value="#prefs.set2_nirvanix_pass#" /></td>
			</tr>
			<tr>
				<td><input type="button" name="validate" value="#defaultsObj.trans("validate")#" class="button" onclick="loadcontent('divvalidate','#myself#c.prefs_nvx_validate&nvxname=' + escape(document.getElementById('set2_nirvanix_name').value) + '&nvxpass=' + escape(document.getElementById('set2_nirvanix_pass').value));" /></td>
				<td><div id="divvalidate"></div></td>
			</tr>
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon">
			<tr>
				<th class="textbold" colspan="2">Amazon / Eucalyptus Bucket</th>
			</tr>
			<tr>
				<td colspan="2">Every host has their own bucket for storing assets. Please enter the name of your bucket in the field below and click on validate to check that we can read/write to it.</td>
			</tr>
			<tr>
				<td colspan="2">NOTE: Define a EXISTING bucket here! Also make sure the bucket is in your defined region. You authenticated Razuna on AWS with the region "#application.razuna.awslocation#".</td>
			</tr>
			<tr>
				<td>Bucket Name</td>
				<td><input type="text" name="set2_aws_bucket" id="set2_aws_bucket" size="40" value="#prefs.set2_aws_bucket#" /></td>
			</tr>
			<tr>
				<td></td>
				<td><input type="button" name="validate" value="#defaultsObj.trans("validate")#" class="button" onclick="loadcontent('divvalidateaws','#myself#c.prefs_aws_bucket_validate&awsbucket=' + escape($('##set2_aws_bucket').val()));" /><div id="divvalidateaws"></div>
				<br />
				<div id="divvalidateaws"></div>
				</td>
			</tr>
		<!--- Akamai --->
		<cfelseif application.razuna.storage EQ "akamai">
			<tr>
				<th class="textbold" colspan="2">Akamai</th>
			</tr>
			<tr>
				<td colspan="2">Every host has their own URL and folder settings for storing assets.</td>
			</tr>
			<tr>
				<td colspan="2">NOTE: In order for this to work you need to contact your Akamai representative to configure and publish a "Akamai configuration"!</td>
			</tr>
			<tr>
				<td nowrap="nowrap">Akamai URL</td>
				<td><input type="text" name="set2_aka_url" id="set2_aka_url" size="40" value="#prefs.set2_aka_url#" style="width:400px;" /> <em>(inkl. http://)</em></td>
			</tr>
			<tr>
				<td nowrap="nowrap">Images Path</td>
				<td><input type="text" name="set2_aka_img" id="set2_aka_img" size="40" value="#prefs.set2_aka_img#" style="width:400px;" /> <em>(e.g. /images)</em></td>
			</tr>
			<tr>
				<td nowrap="nowrap">Videos Path</td>
				<td><input type="text" name="set2_aka_vid" id="set2_aka_vid" size="40" value="#prefs.set2_aka_vid#" style="width:400px;" /> <em>(e.g. /videos)</em></td>
			</tr>
			<tr>
				<td nowrap="nowrap">Documents Path</td>
				<td><input type="text" name="set2_aka_doc" id="set2_aka_doc" size="40" value="#prefs.set2_aka_doc#" style="width:400px;" /> <em>(e.g. /documents)</em></td>
			</tr>
			<tr>
				<td nowrap="nowrap">Audios Path</td>
				<td><input type="text" name="set2_aka_aud" id="set2_aka_aud" size="40" value="#prefs.set2_aka_aud#" style="width:400px;" /> <em>(e.g. /audios)</em></td>
			</tr>
		</cfif>
	</table>

</cfoutput>
