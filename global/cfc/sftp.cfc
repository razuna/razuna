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
<cfcomponent>

	<!--- FUNCTION: INIT --->
	<cffunction name="init" returntype="sftp" access="public" output="false">
		<!--- Return --->
		<cfreturn this />
	</cffunction>

	<cffunction name="connect" access="public" output="false">


	</cffunction>


</cfcomponent>



<cfscript>
FTPSERVER = "web.smsb.com";
FTPPORT = "22";
FTPUSER = "dollar_tree";
FTPPW = "X8yXcxR&X8XAv2wB";

jschObj = createobject('java',"com.jcraft.jsch.JSch");
jschSession = jschObj.getSession(FTPUSER, FTPSERVER);
jschConfig = createObject("java","java.util.Properties");
jschConfig.put("StrictHostKeyChecking","no");
jschConfig.put("compression.s2c", "zlib,none"); //server to client
jschConfig.put("compression.c2s", "zlib,none"); //client to server
jschSession.setConfig(jschConfig);
jschSession.setPort(FTPPORT);
jschSession.setPassword(FTPPW);
jschSession.connect();
jschChannel = jschSession.openChannel("sftp");
jschChannel.connect();
if (jschSession.isConnected()) {
	WriteOutput("CONNECTED!");
}

theDir = jschChannel.ls("/");
WriteDump(theDir);
WriteDump(theDir.toString());

for ( x=1; x <= ArrayLen(theDir); x=x+1 ){
	WriteDump( theDir[x].getFilename() );
}

FileInputStream = createobject("java", "java.io.FileInputStream").init(expandPath("sftp.cfm"));
jschChannel.put(FileInputStream, "sftp.cfm");
WriteDump(jschChannel);

jschChannel.disconnect();
jschSession.disconnect();
</cfscript>