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
	<div id="browse" style="float:left;width:200px;height:auto;float:left;">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
	<div id="serverfoldercontent" style="width:550px;heigth:400px;float:right;left:220px;padding-bottom:20px;"></div>
	<!--- Load folder view in left side --->
	<script language="javascript">
		loadcontent('browse','#myself##xfa.serverfolders#&folder_id=#folder_id#&folderpath=#urlencodedformat(thispath)#');
	</script>
</cfoutput>