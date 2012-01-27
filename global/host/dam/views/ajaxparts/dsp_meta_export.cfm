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
#defaultsObj.trans("header_export_metadata_desc")# <br /><br />
<div>
	<div style="float:left;padding-top:7px;">#defaultsObj.trans("total_amount")#</div> 
	<div style="float:right;"><select id="export_format"><option value="" selected="selected">#defaultsObj.trans("choose_format")#</option><option value="xlsx">XLSX</option><option value="xls">XLS</option><option value="csv">CSV</option></select><span style="padding-right:7px;"></span><input type="button" value="#defaultsObj.trans("export")#" onclick="exportfile()" />
	</div>
</div>
<script type="text/javascript">
	function exportfile(){
		//Get export format
		var format = $('##export_format option:selected').val();
		// Only if select is a format
		if (format != ''){
			window.open('#myself#c.meta_export_do&what=#attributes.what#&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&format=' + format)
		}
	}
</script>
</cfoutput>