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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Uploading from WP Plugin</title>
</head>
<body>
<cfparam name="redirectto" default="">
<form action="http://#hostname#/index.cfm" name="up" method="post" enctype="multipart/form-data">
<input type="hidden" name="fa" value="c.apiupload">
<input type="hidden" name="sessiontoken" value="#thesessiontoken#">
<input type="hidden" name="destfolderid" value="#thefolderid#">
<input type="hidden" name="redirectto" value="#redirectto#">
<input type="file" id="filedata" name="filedata">
<input type="submit" value="send it">
</form>
</body>
</html>
</cfoutput>
