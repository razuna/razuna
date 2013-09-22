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
<cfparam default="0" name="attributes.folder_id">
<cfoutput>
	<form action="#self#" name="pdfsetting" method="post" target="_blank">
	<input type="hidden" name="#theaction#" value="c.topdf">
	<input type="hidden" name="folder_id" value="#attributes.folder_id#">
	<input type="hidden" name="kind" value="#attributes.kind#">
	<input type="hidden" name="offset" value="#session.offset#">
	<input type="hidden" name="rowmaxpage" value="#session.rowmaxpage#">
	<!--- For details --->
	<cfif attributes.kind EQ "detail">
		<input type="hidden" name="thetype" value="#attributes.thetype#">
		<input type="hidden" name="file_id" value="#attributes.file_id#">
		<input type="hidden" name="view" value="#attributes.kind#">
		<input type="hidden" name="format" value="">
	</cfif>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="2">#myFusebox.getApplicationData().defaults.trans("pdf_window_title")#</th>
		</tr>
		<tr>
			<td colspan="2">#myFusebox.getApplicationData().defaults.trans("pdf_window_desc")#</td>
		</tr>
		<cfif attributes.kind NEQ "detail">
			<tr>
				<td valign="top">#myFusebox.getApplicationData().defaults.trans("pdf_pages")#</td>
				<td>
					<input type="radio" name="pages" value="current" checked="true"> #myFusebox.getApplicationData().defaults.trans("current")#<br />
					<input type="radio" name="pages" value="all"> #myFusebox.getApplicationData().defaults.trans("all")#<br />
					<!--- <input type="radio" name="pages" value="custom"> #myFusebox.getApplicationData().defaults.trans("from")#: <input type="text" name="pages_from" size="2"> #myFusebox.getApplicationData().defaults.trans("to")#: <input type="text" name="pages_to" size="2"> --->
				</td>
			</tr>
		</cfif>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("pdf_pagetype")#</td>
			<td>
				<select name="pagetype" style="width:150px;font-size:11px;">
					<option value="letter">US Letter</option>
					<option value="legal">US Legal</option>
					<option value="A4">A4</option>
					<option value="A5">A5</option>
					<option value="B5">B5</option>
					<!--- <option value="custom">Custom</option> --->
				</select>
			</td>
		</tr>
		<cfif attributes.kind NEQ "detail">
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("view")#</td>
				<td><input type="radio" name="view" value="list" checked="true"> #myFusebox.getApplicationData().defaults.trans("list")# <input type="radio" name="view" value="thumbnails"> #myFusebox.getApplicationData().defaults.trans("thumbnails")#</td>
			</tr>
			<input type="hidden" name="format" value="9" />
			<!--- <tr>
				<td>#myFusebox.getApplicationData().defaults.trans("pdf_format")#</td>
				<td>
					<select name="format" style="width:200px;font-size:11px;">
						<option value="9">3 x 3 (9 #myFusebox.getApplicationData().defaults.trans("pdf_assetspage")#)</option>
						<option value="12">4 x 3 (12 #myFusebox.getApplicationData().defaults.trans("pdf_assetspage")#)</option>
						<option value="16">4 x 4 (16 #myFusebox.getApplicationData().defaults.trans("pdf_assetspage")#)</option>
						<option value="25">5 x 5 (25 #myFusebox.getApplicationData().defaults.trans("pdf_assetspage")#)</option>
						<!--- <option value="custom">Custom</option> --->
					</select>
				</td>
			</tr> --->
		</cfif>
		<tr>
			<td valign="top">#myFusebox.getApplicationData().defaults.trans("pdf_header")#</td>
			<td><textarea name="header" style="width:250px;height;40px;"></textarea><br />#myFusebox.getApplicationData().defaults.trans("pdf_header_desc")#</td>
		</tr>
		<tr>
			<td valign="top">#myFusebox.getApplicationData().defaults.trans("pdf_footer")#</td>
			<td><textarea name="footer" style="width:250px;height;40px;"></textarea><br />#myFusebox.getApplicationData().defaults.trans("pdf_footer_desc")#</td>
		</tr>
		<tr>
			<td colspan="2" align="right"><input type="submit" value="#myFusebox.getApplicationData().defaults.trans("pdf_create_button")#" class="button"></td>
		</tr>
	</table>
	</form>	
</cfoutput>
	
