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
Razuna can export your users into multiple formats. Please select the export format you'd like below. <br /><br />
<div>
	<strong><a href="##" onclick="exportfile('csv');">Export to CSV</a></strong><br />
	This format is useful for those who want to move their users to a database or a spreadsheet. The file is saved in CSV (Comma Separated Values) format.
	<br /><br />
	<strong><a href="##" onclick="exportfile('xlsx');">Export to Excel as XLSx</a></strong><br />
	This format exports all your users into the new Microsoft Excel file format. It's the best format to use if you want to move your users to Excel.
	<br /><br />
	<strong><a href="##" onclick="exportfile('xls');">Export to Excel as XLS</a></strong><br />
	This format exports all your users into the older Microsoft Excel file format. It's the best format to use if you want to move your users to Excel.
</div>
<script type="text/javascript">
	function exportfile(theformat){
		// Only if select is a format
		if (theformat != ''){
			window.open('#myself#c.users_export_do&format=' + theformat + '&_v=#createuuid()#');
		}
	}
</script>
</cfoutput>