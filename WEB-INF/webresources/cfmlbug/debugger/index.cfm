<!---
 *  Copyright (C) 2000 - 2012 TagServlet Ltd
 *
 *  This file is part of Open BlueDragon (OpenBD) CFML Server Engine.
 *
 *  OpenBD is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  Free Software Foundation,version 3.
 *
 *  OpenBD is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with OpenBD.  If not, see http://www.gnu.org/licenses/
 *
 *  Additional permission under GNU GPL version 3 section 7
 *
 *  If you modify this Program, or any covered work, by linking or combining
 *  it with any of the JARS listed in the README.txt (or a modified version of
 *  (that library), containing parts covered by the terms of that JAR, the
 *  licensors of this Program grant you additional permission to convey the
 *  resulting work.
 *  README.txt @ http://www.openbluedragon.org/license/README.txt
 *
 *  http://www.openbluedragon.org/
 --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html lang="en">
<head>
	<title>CFMLBug: Debugger</title>
</head>

<frameset rows="40px,*" title="" frameborder="no">
	<frame src="cfmlbug.cfres?_f=debugger/top-frame.cfm?_cfmlbug" name="topframe" title="" scrolling="no" noresize="true">
	<frameset cols="250px,*" title="">
		<frame src="cfmlbug.cfres?_f=debugger/fileexplorer.cfm?_cfmlbug" name="filelistframe" title="Current File System">

		<frameset rows="*,150px,150px">
			<frame src="cfmlbug.cfres?_f=debugger/welcome.cfm?_cfmlbug" name="fileframe" title="File Frame" scrolling="auto">
			<frame src="cfmlbug.cfres?_f=debugger/cfmlbug.cfres?_f=debugger/sessions.cfm?_cfmlbug" name="sessionframe" scrolling="auto">
			<frame src="cfmlbug.cfres?_f=debugger/breakpoints.cfm?_cfmlbug" name="breakpointframe" scrolling="auto">
		</frameset>
	</frameset>

	<noframes></noframes>
</frameset>

</html>