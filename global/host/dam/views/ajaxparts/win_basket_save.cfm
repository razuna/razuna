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
	<!--- Save as a Zip --->
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr>
			<th>#defaultsObj.trans("basket_save_as_zip")#</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("basket_save_as_zip_desc")#</td>
		</tr>
		<tr>
			<td align="right"><input type="button" name="saveaszip" value="#defaultsObj.trans("basket_save_as_zip_button")#" class="button" onclick="showwindow('#myself#c.basket_saveas_zip','#defaultsObj.trans("basket_save_as_zip_button")#',600,1);" /></td>
		</tr>
	</table>
	<hr class="theline" />
	<!--- Save as a Collection --->
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr>
			<th>#defaultsObj.trans("basket_save_as_collection")#</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("basket_save_as_collection_desc")#</td>
		</tr>
		<tr>
			<td align="right"><input type="button" name="saveascol" value="#defaultsObj.trans("basket_save_as_collection_button")#" class="button" onclick="showwindow('#myself#c.basket_saveas_collection','#defaultsObj.trans("basket_save_as_collection_button")#',600,1);" /></td>
		</tr>
	</table>
	<hr class="theline" />
	<!--- Save into existing Collection --->
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr>
			<th>#defaultsObj.trans("basket_save_as_ext_collection")#</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("basket_save_as_ext_collection_desc")#</td>
		</tr>
			<tr>
				<td align="right"><input type="button" name="saveascol" value="#defaultsObj.trans("basket_save_as_ext_collection_button")#" class="button" onclick="showwindow('#myself#c.basket_choose_collection','#defaultsObj.trans("basket_save_as_collection_button")#',600,1);" /></td>
			</tr>
	</table>
</cfoutput>