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

<!--- DO A QUICKSEARCH --->
<cffunction name="quicksearch">
	<cfargument name="thestruct" type="Struct">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<!--- function body --->
	<cfquery datasource="#application.razuna.datasource#" name="localquery">
		SELECT u.user_id, u.user_login_name, u.user_first_name, u.user_last_name, u.user_email, u.user_company, u.user_active, count(*)<cfif application.razuna.thedatabase EQ "oracle"> over()</cfif> total,
		(
		SELECT <cfif application.razuna.thedatabase EQ "mssql">TOP 1 </cfif>min(ct_g_u_grp_id)
		FROM ct_groups_users
		WHERE ct_g_u_user_id = u.user_id
		<cfif application.razuna.thedatabase EQ "oracle">
			AND ROWNUM = 1
		<cfelseif application.razuna.thedatabase EQ "db2">
			FETCH FIRST 1 ROWS ONLY
		<cfelseif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
			LIMIT 1
		</cfif>
		) AS ct_g_u_grp_id
		FROM ct_users_hosts ct, users u
		WHERE ct.ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<!--- user not "admin"
		AND u.user_login_name <> <cfqueryparam cfsqltype="cf_sql_varchar" value="admin"> --->
		AND ct.ct_u_h_user_id = u.user_id
		<cfif arguments.thestruct.user_email IS NOT "">
			AND lower(u.user_email) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.thestruct.user_email)#%">
		</cfif>
		<cfif arguments.thestruct.user_login_name IS NOT "">
			AND
			(
			lower(u.user_login_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.thestruct.user_login_name)#%">
			OR
			lower(u.user_first_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.thestruct.user_login_name)#%">
			OR
			lower(u.user_last_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.thestruct.user_login_name)#%">
			)
		</cfif>
		<cfif arguments.thestruct.user_company IS NOT "">
			AND lower(u.user_company) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.thestruct.user_company)#%">
		</cfif>
		<cfif structkeyexists(arguments.thestruct,"dam")>
			AND lower(u.user_in_dam) = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
		</cfif>
		GROUP BY u.user_id, u.user_login_name, u.user_first_name, u.user_last_name, u.user_email, u.user_active, u.user_company
		ORDER BY u.user_first_name, u.user_last_name
	</cfquery>
	<!--- If we come from DAM we don't show System Admins --->
	<cfif structkeyexists(arguments.thestruct,"dam")>
		<cfquery dbtype="query" name="localquery">
		SELECT *
		FROM localquery
		WHERE ct_g_u_grp_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
		</cfquery>
	</cfif>
	<cfreturn localquery>
</cffunction>

<!--- Check for existing --->
<cffunction name="check">
	<cfargument name="thestruct" type="Struct">
	<!--- function body --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT u.user_id
	FROM ct_users_hosts ct, users u
	WHERE ct.ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND ct.ct_u_h_user_id = u.user_id
	AND u.user_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
	<cfif structkeyexists(arguments.thestruct,"user_login_name")>
		AND lower(u.user_login_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.user_login_name)#">
	<cfelseif structkeyexists(arguments.thestruct,"user_email")>
		AND lower(u.user_email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.user_email)#">
	</cfif>
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Get all users --->
<cffunction name="getall">
	<cfargument name="thestruct" type="Struct">
	<cfset var localquery = 0>
	<cfquery datasource="#application.razuna.datasource#" name="localquery">
	SELECT u.user_id, u.user_login_name, u.user_first_name, u.user_last_name, u.user_email, u.user_active, u.user_company, 
		(
		SELECT <cfif application.razuna.thedatabase EQ "mssql">TOP 1 </cfif>min(ct_g_u_grp_id)
		FROM ct_groups_users
		WHERE ct_g_u_user_id = u.user_id
		<cfif application.razuna.thedatabase EQ "oracle">
			AND ROWNUM = 1
		<cfelseif application.razuna.thedatabase EQ "db2">
			FETCH FIRST 1 ROWS ONLY
		<cfelseif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
			LIMIT 1
		</cfif>
		) AS ct_g_u_grp_id
	FROM ct_users_hosts uh, users u
	WHERE (
		uh.ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
		AND uh.ct_u_h_user_id = u.user_id
		)
	AND u.user_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
	GROUP BY user_id, user_login_name, user_first_name, user_last_name, user_email, user_active, user_company
	</cfquery>
	<!--- If we come from DAM we don't show System Admins --->
	<cfif structkeyexists(arguments.thestruct,"dam")>
		<cfquery dbtype="query" name="localquery">
		SELECT *
		FROM localquery
		WHERE ct_g_u_grp_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
		</cfquery>
	</cfif>
	<!--- Return --->
	<cfreturn localquery>
</cffunction>

<!--- Get Details from this User --->
<cffunction name="details">
	<cfargument name="thestruct" type="Struct">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="details#arguments.thestruct.user_id##session.hostid#" cachedomain="#session.hostid#_users">
	select user_id, user_login_name, user_email, user_pass, user_first_name, user_last_name, user_in_admin, user_create_date,
	user_active,USER_COMPANY,USER_PHONE,USER_MOBILE,USER_FAX,user_in_dam, user_salutation
	from users
	where user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.user_id#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- GET EMAIL FROM THIS USER --->
<cffunction name="user_email">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="emails#session.theuserid##session.hostid#" cachedomain="#session.hostid#_users">
	SELECT user_email
	FROM users
	WHERE user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
	</cfquery>
	<cfreturn qry.user_email>
</cffunction>

<!--- Get hosts of this user --->
<cffunction name="userhosts">
	<cfargument name="thestruct" type="Struct">
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="hosts#arguments.thestruct.user_id##session.hostid#" cachedomain="#session.hostid#_users">
		SELECT h.host_id, h.host_name, h.host_db_prefix, h.host_shard_group, h.host_path
		FROM ct_users_hosts ct, hosts h
		WHERE ct.ct_u_h_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.user_id#">
		AND ct.ct_u_h_host_id = h.host_id
		</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Add user --->
<cffunction name="add">
	<cfargument name="thestruct" type="Struct">
	<cfparam default="F" name="arguments.thestruct.user_active">
	<cfparam default="F" name="arguments.thestruct.adminuser">
	<cfparam default="F" name="arguments.thestruct.intrauser">
	<cfparam default="F" name="arguments.thestruct.vpuser">
	<!--- Check that there is no user already with the same email address --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_sameuser">
	SELECT u.user_email, u.user_login_name
	FROM users u, ct_users_hosts ct
	WHERE (
		lower(u.user_email) = <cfqueryparam value="#lcase(arguments.thestruct.user_email)#" cfsqltype="cf_sql_varchar">
		OR lower(u.user_login_name) = <cfqueryparam value="#lcase(arguments.thestruct.user_login_name)#" cfsqltype="cf_sql_varchar">
		)
	AND ct.ct_u_h_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
	AND ct.ct_u_h_user_id = u.user_id
	</cfquery>
	<!--- Not the same user thus go on --->
	<cfif qry_sameuser.RecordCount EQ 0>
		<cfset newid = 0>
		<!--- Create new ID --->
		<!--- <cfinvoke component="global" method="getsequence" returnvariable="newid" database="#application.razuna.thedatabase#" dsn="#application.razuna.datasource#" thetable="users" theid="user_id"> --->
		<!--- Hash Password --->
		<cfset thepass = hash(arguments.thestruct.user_pass, "MD5", "UTF-8")>
		<!--- Insert the User into the DB --->
		<cftransaction>
			<cfset newid = createuuid()>
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO users
			(user_id, user_login_name, user_email, user_pass, user_first_name, user_last_name, user_in_admin,
			user_create_date, user_active, user_company, user_phone, user_mobile, user_fax, user_in_dam, user_salutation, user_in_vp)
			VALUES(
			<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#arguments.thestruct.user_login_name#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.user_email#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#thepass#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.user_first_name#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.user_last_name#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.adminuser#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			<cfqueryparam value="#arguments.thestruct.user_active#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.user_company#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.user_phone#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.user_mobile#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.user_fax#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.intrauser#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.user_salutation#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.vpuser#" cfsqltype="cf_sql_varchar">
			)
			</cfquery>
		</cftransaction>
		<!--- Insert the user to the user host cross table --->
		<cfloop delimiters="," index="thehostid" list="#arguments.thestruct.hostid#">
			<cftransaction>
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO ct_users_hosts
				(ct_u_h_user_id, ct_u_h_host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#thehostid#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			</cftransaction>
		</cfloop>
		<!--- Log --->
		<cfif structkeyexists(arguments.thestruct,"dam")>
			<cfset logsection = "DAM">
		<cfelse>
			<cfset logsection = "Admin">
		</cfif>
		<cfset log = #log_users(theuserid=newid,logaction='Add',logsection='#logsection#',logdesc='Added: UserID: #newid# eMail: #arguments.thestruct.user_email# First Name: #arguments.thestruct.user_first_name# Last Name: #arguments.thestruct.user_last_name#')#>
		<!--- Flush Cache --->
		<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.hostid#_users" />
	<cfelse>
		<cfset newid = 0>
	</cfif>
	<!--- Return --->
	<cfreturn newid>
</cffunction>

<!--- Delete user --->
<cffunction name="delete">
	<cfargument name="thestruct" type="Struct">
	<!--- remove all cross-table entries first -------------------------------------------- --->
	<!--- Remove from the host table --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM ct_users_hosts
	WHERE ct_u_h_user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Remove Intra/extranet carts  --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#cart
	WHERE user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Remove user comments  --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM users_comments
	WHERE user_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- att ct-entries removed, now remove the record itself -------------------------------------------- --->
	<!--- Get detail of user first --->
	<cfset arguments.thestruct.user_id = arguments.thestruct.id>
	<cfinvoke method="details" thestruct="#arguments.thestruct#" returnvariable="theuser">
	<!--- Log --->
	<cfif NOT structkeyexists(arguments.thestruct,("logsection"))>
		<cfset arguments.thestruct.logsection = "admin">
	</cfif>
	<cfset log = #log_users(theuserid=arguments.thestruct.id,logaction='Delete',logsection='#arguments.thestruct.logsection#',logdesc='Deleted: UserID: #arguments.thestruct.id# eMail: #theuser.user_email# First Name: #theuser.user_first_name# Last Name: #theuser.user_last_name#')#>
	<!--- Remove from the User Table --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM users
	WHERE user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Flush Cache --->
	<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.hostid#_users" />
	
	<cfreturn />
</cffunction>

<!--- Update user --->
<cffunction name="update">
	<cfargument name="thestruct" type="Struct">
	<cfparam default="F" name="arguments.thestruct.user_active">
	<cfparam default="F" name="arguments.thestruct.adminuser">
	<cfparam default="F" name="arguments.thestruct.intrauser">
	<!--- Check that there is no user already with the same email address. Since this is the detail we already have a user with the same email address so we exclude this user from the search --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_sameuser">
	SELECT u.user_email, u.user_id
	FROM users u, ct_users_hosts ct
	WHERE lower(u.user_email) = <cfqueryparam value="#lcase(arguments.thestruct.user_email)#" cfsqltype="cf_sql_varchar">
	AND ct.ct_u_h_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
	AND ct.ct_u_h_user_id = u.user_id
	AND u.user_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- There is no user with the same name thus continue --->
	<cfif qry_sameuser.RecordCount EQ 0>
		<!--- First remove the admin user value --->
		<cfif NOT structkeyexists(arguments.thestruct,"dam")>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE users
			SET user_in_admin = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">,
			user_in_dam = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">
			WHERE user_id = <cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
		<!--- Hash Password --->
		<cfset thepass = hash(arguments.thestruct.user_pass, "MD5", "UTF-8")>
		<!--- Update the User in the DB --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE users
		SET
		user_login_name=<cfqueryparam value="#arguments.thestruct.user_login_name#" cfsqltype="cf_sql_varchar">,
		user_email=<cfqueryparam value="#arguments.thestruct.user_email#" cfsqltype="cf_sql_varchar">
		<cfif arguments.thestruct.user_pass IS NOT "">
			, user_pass=<cfqueryparam value="#thepass#" cfsqltype="cf_sql_varchar">
		</cfif>,
		user_first_name=<cfqueryparam value="#arguments.thestruct.user_first_name#" cfsqltype="cf_sql_varchar">,
		user_last_name=<cfqueryparam value="#arguments.thestruct.user_last_name#" cfsqltype="cf_sql_varchar">,
		<!--- If we are coming from the DAM then exclude --->
		<cfif NOT structkeyexists(arguments.thestruct,"dam")>
			user_in_admin = <cfqueryparam value="#arguments.thestruct.adminuser#" cfsqltype="cf_sql_varchar">,
		</cfif>
		user_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
		user_active = <cfqueryparam value="#arguments.thestruct.user_active#" cfsqltype="cf_sql_varchar">,
		USER_COMPANY = <cfqueryparam value="#arguments.thestruct.USER_COMPANY#" cfsqltype="cf_sql_varchar">,
		USER_PHONE = <cfqueryparam value="#arguments.thestruct.USER_PHONE#" cfsqltype="cf_sql_varchar">,
		USER_MOBILE = <cfqueryparam value="#arguments.thestruct.USER_MOBILE#" cfsqltype="cf_sql_varchar">,
		USER_FAX = <cfqueryparam value="#arguments.thestruct.USER_FAX#" cfsqltype="cf_sql_varchar">,
		user_in_dam = <cfqueryparam value="#arguments.thestruct.intrauser#" cfsqltype="cf_sql_varchar">,
		user_salutation = <cfqueryparam value="#arguments.thestruct.user_salutation#" cfsqltype="cf_sql_varchar">
		WHERE user_id = <cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Insert the user to the user host cross table --->
		<!--- First remove all value for this user --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM ct_users_hosts
		WHERE ct_u_h_user_id = <cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Insert the user to the user host cross table --->
		<cfloop delimiters="," index="thehostid" list="#arguments.thestruct.hostid#">
			<cfquery datasource="#application.razuna.datasource#">
			insert into ct_users_hosts
			(ct_u_h_user_id, ct_u_h_host_id, rec_uuid)
			values(
			<cfqueryparam value="#arguments.thestruct.user_id#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#thehostid#" cfsqltype="CF_SQL_NUMERIC">,
			<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
		</cfloop>
		<!--- Log --->
		<cfif structkeyexists(arguments.thestruct,"dam")>
			<cfset logsection = "DAM">
		<cfelse>
			<cfset logsection = "Admin">
		</cfif>
		<cfset log = #log_users(theuserid=arguments.thestruct.user_id,logsection='#logsection#',logaction='Update',logdesc='Updated: UserID: #arguments.thestruct.user_id# eMail: #arguments.thestruct.user_email# First Name: #arguments.thestruct.user_first_name# Last Name: #arguments.thestruct.user_last_name#')#>
	</cfif>
	<!--- Flush Cache --->
	<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.hostid#_users" />
	
	<cfreturn />
</cffunction>

<!--- Confirm user --->
<cffunction name="confirm">
	<cfargument name="thestruct" type="Struct">
	<cfparam default="0" name="arguments.thestruct.id">
	<!--- Check that there is a user with this id --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT u.user_id
	FROM users u, ct_users_hosts ct
	WHERE u.user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND ct.ct_u_h_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
	AND ct.ct_u_h_user_id = u.user_id
	</cfquery>
	<!--- There is a user thus continue --->
	<cfif qry.RecordCount EQ 1>
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE users
		SET user_active = <cfqueryparam value="T" cfsqltype="cf_sql_varchar">
		WHERE user_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Set var --->
		<cfset arguments.thestruct.id = arguments.thestruct.id>
		
		
	<cfelse>
		<!--- Set var --->
		<cfset arguments.thestruct.id = 0>
	</cfif>
	<!--- Return --->
	<cfreturn arguments.thestruct.id>
</cffunction>


</cfcomponent>