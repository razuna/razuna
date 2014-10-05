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

<!--- ***** This component is designed for error handling functions such as logging errors ***** --->

<cfcomponent output="false">
	<!--- FUNCTION: INIT --->
	<cffunction name="init" returntype="errors" access="public" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="logerrors" access="public" returntype="void" hint="Accepts data from cfcatch and logs it in the database along with other debug information. Meant to be called inside a cfcatch block ">
		<cfargument name="cfcatch" required="true" type="any" hint="cfcatch structure with error details">
		<cfargument name="showmsg" required="false" type="boolean" default="true" hint="display message to user or not">
		<cfparam name="arguments.cfcatch.custom_message" default="N/A">

		<cfif arguments.showmsg>
			<!--- Output to user --->
			<h2 style="color:red;">We are so sorry. Something went wrong. <cfif (isdefined("application.razuna.isp") AND application.razuna.isp) OR cgi.http_host CONTAINS "razunabd.local">We have been notified of this error and will fix it asap.<cfelse>We saved the error and you or your administrator can notify us of this error within the Administration.</cfif></h2>
		</cfif>
		<!--- Save content --->
		<cfsavecontent variable="errortext">
		<cfoutput>
		<h3 style="color:indianred">An error occurred: http://#cgi.server_name##cgi.script_name#?#cgi.query_string#</h3>
		<strong>Time:</strong> #dateFormat(now(), "short")# #timeFormat(now(), "short")#<br />

		<cfdump var="#arguments.cfcatch#" label="Error">
		<cfif IsStruct("session")>
			<cfdump var="#session#" label="Session">
		</cfif>
		<cfif isStruct("form")>
			<cfdump var="#form#" label="Form">
		</cfif>
		<cfif isStruct("url")>
			<cfdump var="#url#" label="URL">
		</cfif>
		</cfoutput>
		</cfsavecontent>
		<!--- Increment ID --->
		<cfquery datasource="#application.razuna.datasource#" name="qryid">
		SELECT <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(max(id),0) + 1 as theid
		FROM #session.hostdbprefix#errors
		</cfquery>
		<cftry>
			<!--- Add to DB assuming err_header column is present --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#errors
			(id, err_header,err_text, err_date, host_id)
			VALUES(
			<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#qryid.theid#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.cfcatch.custom_message#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#errortext#">,
			<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
			<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
			)
			</cfquery>
			<cfcatch type="database">
				<!--- Add to DB assuming err_header column is not present if error occurs above --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#errors
				(id, err_text, err_date, host_id)
				VALUES(
				<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#qryid.theid#">,
				<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#errortext#">,
				<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
				<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
				)
				</cfquery>
			</cfcatch>
		</cftry>
		<!--- Flush Cache --->
		<cfinvoke component="extQueryCaching" method="resetcachetoken" type="logs" />
		<!--- eMail --->
		<cfif cgi.http_host CONTAINS "razuna.com">
			<cfmail to="bugs@razuna.com" from="server@razuna.com" subject="Razuna Error: #cgi.server_name#" type="html">
			#errortext#
			</cfmail>
		</cfif>
	</cffunction>
</cfcomponent>