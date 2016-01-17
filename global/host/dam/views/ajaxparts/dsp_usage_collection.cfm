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
	<h2>Find below a list of collection(s) that this file is associated with</h2>
	<p>Click on collection below to jump to the collection itself.</p>
	<cfloop query="qry_usage">
		<h3>
			<a href="##" onclick="loadCol('#col_id_r#', '#folder_id_r#')">#col_name#</a></h3>
	</cfloop>
	


	<script type="text/javascript">
		function loadCol(col_id, folder_id) {
			// Close window
			destroywindow(1);
			// go to collection
			loadcontent('rightside','#myself#c.collection_detail&col_id=' + col_id + '&folder_id=' + folder_id);
		}
	</script>

</cfoutput>