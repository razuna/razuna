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
		<!--- Connection --->
		<cfset this.connection = structNew()>
		<!--- Return --->
		<cfreturn this />
	</cffunction>

	<cffunction name="connect" access="public" output="false">
		<cfargument name="host" type="string" required="true" />
		<cfargument name="port" type="string" required="true" />
		<cfargument name="user" type="string" required="true" />
		<cfargument name="pass" type="string" required="true" />

		<cfset var FTPSERVER = arguments.host>
		<cfset var FTPPORT = arguments.port>
		<cfset var FTPUSER = arguments.user>
		<cfset var FTPPW = arguments.pass>

		<cfset var jschObj = createobject('java',"com.jcraft.jsch.JSch")>
		<cfset var jschConfig = createObject("java","java.util.Properties")>

		<cfset var jschSession = jschObj.getSession(FTPUSER, FTPSERVER)>

		<cfset jschConfig.put("StrictHostKeyChecking","no")>
		<cfset jschConfig.put("compression.s2c", "zlib,none")>
		<cfset jschConfig.put("compression.c2s", "zlib,none")>
		<cfset jschSession.setConfig(jschConfig)>
		<cfset jschSession.setPort(FTPPORT)>
		<cfset jschSession.setPassword(FTPPW)>

		<!--- Connect --->
		<cfset jschSession.connect()>
		<cfset var jschChannel = jschSession.openChannel("sftp")>
		<cfset jschChannel.connect()>

		<cfset var connected = jschSession.isConnected()>

		<!--- The result --->
		<cfset var _connection = structNew()>
		<cfset _connection.connected = connected>
		<cfset _connection.sftpChannel = jschChannel>
		<cfset _connection.sftpSession = jschSession>

		<!--- Store connection --->
		<cfset this.connection = _connection>

		<!--- <cfset consoleoutput(true, true)>
		<cfset console(jschObj)>
		<cfset console(jschConfig)>
		<cfset console(jschSession)>
		<cfset console("CHANNEL:", jschChannel)>
		<cfset console("connected", connected)>
		<cfset console("RESULT", _connection)>
		<cfset console("THIS", this.connection)> --->

		<!--- Return --->
		<cfreturn this />
	</cffunction>

	<cffunction name="disconnect" access="public" output="false">
		<!--- <cfset console("DISCONNECT", this.connection)> --->
		<cfset this.connection.sftpChannel.disconnect()>
		<cfset this.connection.sftpSession.disconnect()>
		<cfset this.connection.connected = false>
		<cfset this.connection.sftpChannel = "">
		<cfset this.connection.sftpSession = "">
		<cfreturn this />
	</cffunction>

	<cffunction name="list" access="public" output="false">
		<cfargument name="path" type="string" required="true" default="/" />

		<cfset var _result = structNew()>
		<cfset _list = arraynew()>

		<cfset _result.directory = arguments.path>
		<cfset _result.list_object = this.connection.sftpChannel.ls( arguments.path )>
		<!--- <cfset consoleoutput(true, true)> --->

		<cfloop array="#_result.list_object#" index="i" item="f">
			<!--- <cfset console('F ATTR : ', _result.list_object[i].getAttrs() )>
			<cfset console('F LONGNAME : ', _result.list_object[i].getLongname() )> --->
			<cfset arrayappend( _list, _result.list_object[i].getFilename() )>
		</cfloop>

		<cfset _result.list = _list>

		<cfreturn _result />
	</cffunction>

	<cffunction name="put" access="public" output="false">
		<cfargument name="file_local" type="string" required="true" />
		<cfargument name="file_remote" type="string" required="true" />

		<cfset var _file = "">
		<cfset var _result = structNew()>
		<cfset _result.file_local = arguments.file_local>
		<cfset _result.file_remote = arguments.file_remote>

		<cfset var FileInputStream = createobject("java", "java.io.FileInputStream").init( expandPath( arguments.file_local ) )>
		<cfset this.connection.sftpChannel.put(FileInputStream, arguments.file_remote, this.connection.sftpChannel.OVERWRITE)>

		<!--- Check if file is there --->
		<cftry>
			<cfset _file = this.connection.sftpChannel.ls( arguments.file_remote )>
			<cfcatch>
				<cfset _file = arrayNew()>
			</cfcatch>
		</cftry>

		<!--- Set status --->
		<cfset _result.status = ArrayLen(_file) ? true : false>

		<!--- Return --->
		<cfreturn _result />
	</cffunction>

</cfcomponent>
