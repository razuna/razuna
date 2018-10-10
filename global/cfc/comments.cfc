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
<cfcomponent extends="extQueryCaching">

<!--- GET HOW MANY COMMENTS THERE ARE FOR THIS ASSET --->
<cffunction name="howmany" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
	SELECT count(com_id) thetotal
	FROM #arguments.thestruct.razuna.session.hostdbprefix#comments
	WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_show#">
	</cfquery>
	<!--- Return --->
	<cfreturn qry.thetotal>
</cffunction>

<!--- GET COMMENTS FOR THIS ASSET --->
<cffunction name="get" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
	SELECT c.com_id, c.com_text, c.com_date, u.user_login_name, u.user_first_name, u.user_last_name
	FROM #arguments.thestruct.razuna.session.hostdbprefix#comments c LEFT JOIN users u ON u.user_id = c.user_id_r
	WHERE c.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND c.asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">
	ORDER BY c.com_date DESC
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- GET LATEST COMMENTS FOR THIS ASSET --->
<cffunction name="getlatest" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
	SELECT <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">TOP 1 </cfif>c.com_id, c.com_text, c.com_date, u.user_login_name, u.user_first_name, u.user_last_name
	FROM #arguments.thestruct.razuna.session.hostdbprefix#comments c LEFT JOIN users u ON u.user_id = c.user_id_r
	WHERE c.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND c.asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">
	<cfif arguments.thestruct.razuna.application.thedatabase EQ "oracle">
		AND ROWNUM = 1
	</cfif>
	ORDER BY c.com_date DESC
	<cfif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">
		LIMIT 1
	</cfif>
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- GET COMMENT --->
<cffunction name="edit" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
	SELECT c.com_id, c.com_text, c.com_date, u.user_login_name, u.user_first_name, u.user_last_name
	FROM #arguments.thestruct.razuna.session.hostdbprefix#comments c LEFT JOIN users u ON u.user_id = c.user_id_r
	WHERE c.com_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.com_id#">
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- ADD NEW COMMENT --->
<cffunction name="add" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<cfif arguments.thestruct.comment NEQ "">
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#comments
		(com_id, com_text, com_date, asset_id_r, user_id_r, asset_type, host_id)
		VALUES(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.razuna.session.newcommentid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.comment#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.razuna.session.theuserid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		)
		</cfquery>
	</cfif>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- REMOVE COMMENT --->
<cffunction name="remove" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
	DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#comments
	WHERE com_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.id#">
	</cfquery>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- UPDATE COMMENT --->
<cffunction name="update" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
	UPDATE #arguments.thestruct.razuna.session.hostdbprefix#comments
	SET com_text = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.comment#">
	WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND com_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.com_id#">
	</cfquery>
	<!--- Return --->
	<cfreturn />
</cffunction>


</cfcomponent>
