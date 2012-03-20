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
<cfcomponent output="false">
	
	<!--- Log user in and create sessiontoken --->
	<cffunction name="login" access="remote" output="false" returntype="string">
		<cfargument name="hostid" type="numeric">
		<cfargument name="user" type="string">
		<cfargument name="pass" type="string">
		<cfargument name="passhashed" type="numeric">
		<cftry>
			<!--- Remove records which are older then now minus 40 minutes --->
			<cfquery datasource="#application.razuna.api.dsn#">
			DELETE FROM webservices
			WHERE timeout < <cfqueryparam value="#DateAdd("n", -40, now())#" cfsqltype="cf_sql_timestamp">
			</cfquery>
			<!--- check if password is hashed or not --->
			<cfif arguments.passhashed>
				<cfset var thepass = arguments.pass>
			<cfelse>
				<cfset var thepass = hash(arguments.pass, "MD5", "UTF-8")>
			</cfif>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT u.user_id, gu.ct_g_u_grp_id grpid
			FROM users u, ct_users_hosts ct, ct_groups_users gu
			WHERE (
				lower(u.user_login_name) = <cfqueryparam value="#lcase(arguments.user)#" cfsqltype="cf_sql_varchar"> 
				OR lower(u.user_email) = <cfqueryparam value="#lcase(arguments.user)#" cfsqltype="cf_sql_varchar">
				)
			AND lower(u.user_pass) = <cfqueryparam value="#lcase(thepass)#" cfsqltype="cf_sql_varchar">
			AND lower(u.user_active) = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
			AND u.user_id = ct.ct_u_h_user_id
			AND ct.ct_u_h_host_id = <cfqueryparam value="#arguments.hostid#" cfsqltype="cf_sql_numeric">
			AND gu.ct_g_u_user_id = u.user_id
			AND (
				gu.ct_g_u_grp_id = <cfqueryparam value="1" cfsqltype="CF_SQL_VARCHAR">
				OR
				gu.ct_g_u_grp_id = <cfqueryparam value="2" cfsqltype="CF_SQL_VARCHAR">
			)
			GROUP BY user_id, ct_g_u_grp_id
			</cfquery>
			<!--- If we find the user we create the sessiontoken --->
			<cfif qry.recordcount NEQ 0>
				<cfset var response = 0>
				<cfset var thetoken = createuuid("")>
				<!--- Append to DB --->
				<cfquery datasource="#application.razuna.api.dsn#">
				INSERT INTO webservices
				(sessiontoken, timeout, groupofuser, userid)
				VALUES(
				<cfqueryparam value="#thetoken#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#DateAdd("n", 30, now())#" cfsqltype="cf_sql_timestamp">,
				<cfqueryparam value="#valuelist(qry.grpid)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
				)
				</cfquery>
				<!--- Get Host prefix --->
				<cfquery datasource="#application.razuna.api.dsn#" name="pre">
				SELECT host_shard_group
				FROM hosts
				WHERE host_id = <cfqueryparam value="#arguments.hostid#" cfsqltype="cf_sql_numeric">
				</cfquery>
				<!--- Set Host information --->
				<cfset application.razuna.api.prefix[#thetoken#] = pre.host_shard_group>
				<cfset application.razuna.api.hostid[#thetoken#] = arguments.hostid>
				<cfset application.razuna.api.userid[#thetoken#] = qry.user_id>
			<!--- Not found --->
			<cfelse>
				<cfset var response = 1>
				<cfset var thetoken = "Access Denied">
			</cfif>
			<!--- Create the XML --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>#response#</responsecode>
<sessiontoken>#thetoken#</sessiontoken>
</Response></cfoutput>
			</cfsavecontent>
			<cfcatch type="any">
				<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="error api login">
					<cfdump var="#cfcatch#" />
				</cfmail>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Check for db entry --->
	<cffunction name="checkdb" access="public" output="false">
		<cfargument name="sessiontoken" type="string">
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry">
		SELECT sessiontoken, timeout
		FROM webservices
		WHERE sessiontoken = <cfqueryparam value="#arguments.sessiontoken#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- If timeout is within the last 30 minutes then extend it again --->
		<cfif qry.recordcount NEQ 0 AND qry.timeout GTE now()>
			<!--- Set --->
			<cfset var status = true>
			<!--- Update DB --->
			<cfquery datasource="#application.razuna.api.dsn#">
			UPDATE webservices
			SET timeout = <cfqueryparam value="#DateAdd("n", 30, now())#" cfsqltype="cf_sql_timestamp">
			WHERE sessiontoken = <cfqueryparam value="#arguments.sessiontoken#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<!--- Timeout --->
		<cfelse>
			<!--- Set --->
			<cfset var status = false>
			<!--- Remove DB --->
			<cfthread>
				<cfquery datasource="#application.razuna.api.dsn#">
				DELETE FROM webservices
				WHERE timeout < <cfqueryparam value="#DateAdd("n", -31, now())#" cfsqltype="cf_sql_timestamp">
				</cfquery>
			</cfthread>
		</cfif>
		<!--- Return --->
		<cfreturn status>
	</cffunction>
	
	<!--- Create timeout error --->
	<cffunction name="timeout" access="public" output="false">
		<!--- Create the XML --->
		<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>Session timeout</message>
</Response></cfoutput>
		</cfsavecontent>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Log user in and create sessiontoken --->
	<cffunction name="loginhost" access="remote" output="false" returntype="String">
		<cfargument name="hostname" type="string">
		<cfargument name="user" type="string">
		<cfargument name="pass" type="string">
		<cfargument name="passhashed" type="numeric">
		<cftry>
			<!--- Remove records which are older then now minus 40 minutes --->
			<cfthread>
				<cfquery datasource="#application.razuna.api.dsn#">
				DELETE FROM webservices
				WHERE timeout < <cfqueryparam value="#DateAdd("n", -40, now())#" cfsqltype="cf_sql_timestamp">
				</cfquery>
			</cfthread>
			<!--- Query for the hostname --->
			<cfset thecount = findoneof(".",arguments.hostname) - 1>
			<cfset thesubdomain = mid(arguments.hostname,1,thecount)>
			<cfquery datasource="#application.razuna.api.dsn#" name="thehost">
			SELECT host_id, host_name, host_db_prefix, host_type, host_shard_group
			FROM hosts
			WHERE lower(host_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(thesubdomain)#">
			</cfquery>
			<!--- If record is found then --->
			<cfif thehost.recordcount EQ 0>
				<cfset thehostid = 0>
			<cfelse>
				<cfset thehostid = thehost.host_id>
			</cfif>
			<!--- check if password is hashed or not --->
			<cfif arguments.passhashed>
				<cfset var thepass = arguments.pass>
			<cfelse>
				<cfset var thepass = hash(arguments.pass, "MD5", "UTF-8")>
			</cfif>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT u.user_id, gu.ct_g_u_grp_id grpid
			FROM users u, ct_users_hosts ct, ct_groups_users gu
			WHERE (
				lower(u.user_login_name) = <cfqueryparam value="#lcase(arguments.user)#" cfsqltype="cf_sql_varchar"> 
				OR lower(u.user_email) = <cfqueryparam value="#lcase(arguments.user)#" cfsqltype="cf_sql_varchar">
				)
			AND lower(u.user_pass) = <cfqueryparam value="#lcase(thepass)#" cfsqltype="cf_sql_varchar">
			AND lower(u.user_active) = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
			AND u.user_id = ct.ct_u_h_user_id
			AND ct.ct_u_h_host_id = <cfqueryparam value="#thehostid#" cfsqltype="cf_sql_numeric">
			AND gu.ct_g_u_user_id = u.user_id
			AND (
				gu.ct_g_u_grp_id = <cfqueryparam value="1" cfsqltype="CF_SQL_VARCHAR">
				OR
				gu.ct_g_u_grp_id = <cfqueryparam value="2" cfsqltype="CF_SQL_VARCHAR">
			)
			</cfquery>
			<!--- If we find the user we create the sessiontoken --->
			<cfif qry.recordcount NEQ 0>
				<cfset var response = 0>
				<cfset var thetoken = createuuid("")>
				<!--- Append to DB --->
				<cfquery datasource="#application.razuna.api.dsn#">
				INSERT INTO webservices
				(sessiontoken, timeout, groupofuser, userid)
				VALUES(
				<cfqueryparam value="#thetoken#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#DateAdd("n", 30, now())#" cfsqltype="cf_sql_timestamp">,
				<cfqueryparam value="#valuelist(qry.grpid)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
				)
				</cfquery>
				<!--- Set Host information --->
				<cfset application.razuna.api.prefix[#thetoken#] = thehost.host_shard_group>
				<cfset application.razuna.api.hostid[#thetoken#] = thehostid>
				<cfset application.razuna.api.userid[#thetoken#] = qry.user_id>
			<!--- Not found --->
			<cfelse>
				<cfset var response = 1>
				<cfset var thetoken = "Access Denied">
			</cfif>
			<!--- Create the XML --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>#response#</responsecode>
<sessiontoken>#thetoken#</sessiontoken>
<hostid>#thehostid#</hostid>
</Response></cfoutput>
			</cfsavecontent>
			<cfcatch type="any">
				<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="error api">
					<cfdump var="#cfcatch#" />
				</cfmail>
				<!--- Create the XML --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<sessiontoken><![CDATA[An error occured. Please check your input parameters. Error detail description: #cfcatch.Detail#]]></sessiontoken>
</Response></cfoutput>
			</cfsavecontent>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
</cfcomponent>