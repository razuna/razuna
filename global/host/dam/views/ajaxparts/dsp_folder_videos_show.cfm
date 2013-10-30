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
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
<head>
<cfoutput>
<!--- Include the JS for showing Quicktime. This is the new Apple Library which fixes IE 7 bugs --->
<script type="text/javascript" src="#dynpath#/global/js/AC_QuickTime.js"></script>
<script type="text/javascript" src="#dynpath#/global/videoplayer/js/flowplayer-3.2.6.min.js"></script>
<!--- <script type="text/javascript" src="#dynpath#/global/videoplayer/js/jquery.pack.js"></script>
<script type="text/javascript" src="#dynpath#/global/videoplayer/js/flashembed.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/videoplayer/js/flow.embed.js"></script> --->
<link type="text/css" rel="stylesheet" href="#dynpath#/global/videoplayer/css/multiple-instances.css" />
<head>
<body>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
	<td align="center">#thevideo#</td>
</tr>
</table>
</cfoutput>
</body>
</html>
