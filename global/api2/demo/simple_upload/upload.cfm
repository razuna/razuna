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
<!DOCTYPE html>
<html>
<head>
<title>Uploading with the API</title>
</head>
<body>
<form action="#application.razuna.api.thehttp#(yourip):8080/raz1/dam/index.cfm" name="up" method="post" enctype="multipart/form-data">
<input type="hidden" name="fa" value="c.apiupload">
<input type="hidden" name="api_key" value="(put your apikey here)">
<input type="hidden" name="destfolderid" value="(put the folderid here)">
<!--- For additional rendition you should give the valid assetid otherwise leave empty --->
<input type="hidden" name="assetid" value="(put your assetid here for additional rendition otherwise leave empty)">
<input type="file" id="filedata" name="filedata">
<input type="submit" value="send it">
</form>
</body>
</html>
</cfoutput>
