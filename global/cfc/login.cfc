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
<cfcomponent displayname="Handels the login for the users" hint="Handels the login for the users" output="false">

<!--- FUNCTION: INIT --->
	<cffunction name="init" returntype="login" access="public" output="false">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="database" type="string" required="yes" />
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.database = arguments.database />
		<cfreturn this />
	</cffunction>

<!--- FUNCTION: LOGIN --->
	<cffunction name="login" displayname="login" hint="Handels login" access="public" output="false" returntype="Any">
		<cfargument name="name" required="yes" type="string">
		<cfargument name="pass" required="yes" type="string">
		<cfargument name="loginto" required="yes" type="string">
		<cfargument name="rem_login" required="no" type="string">
		<cfargument name="from_share" required="no" type="string">
		<!--- Params --->
		<cfparam name="arguments.rem_login" default="F">
		<cfparam name="arguments.from_share" default="F">
		<!--- create structure to store results in --->
		<cfset var theuser = structNew()>
		<cfif arguments.loginto EQ "admin">
			<cfset var thecookie = cookie.loginpassadmin>
		<cfelse>
			<cfset var thecookie = cookie.loginpass>
		</cfif>
		<!--- compare argument and cookie, if it is alredy the hased value use us it else take new password passed --->
		<cfif arguments.pass EQ thecookie>
			<cfset var thepass = thecookie>
		<cfelse>
			<!--- Hash password --->
			<cfset var thepass = hash(arguments.pass, "MD5", "UTF-8")>
		</cfif>
		<!--- Check for the user --->
		<cfquery datasource="#application.razuna.datasource#" name="qryuser" cachename="login#session.hostid##arguments.name##thepass#" cachedomain="#session.hostid#_users">
		SELECT u.user_login_name, u.user_email, u.user_id, u.user_first_name, u.user_last_name
		FROM users u<cfif arguments.loginto NEQ "admin">, ct_users_hosts ct</cfif>
		WHERE (
			lower(u.user_login_name) = <cfqueryparam value="#lcase(arguments.name)#" cfsqltype="cf_sql_varchar"> 
			OR lower(u.user_email) = <cfqueryparam value="#lcase(arguments.name)#" cfsqltype="cf_sql_varchar">
			)
		AND u.user_pass = <cfqueryparam value="#thepass#" cfsqltype="cf_sql_varchar">
		<cfif arguments.loginto EQ "admin">
			AND lower(u.user_in_admin) = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
		<cfelseif arguments.loginto EQ "dam">
			AND lower(u.user_in_dam) = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
		</cfif>
		AND lower(u.user_active) = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
		<cfif arguments.loginto NEQ "admin">
			AND ct.ct_u_h_user_id = u.user_id
			AND ct.ct_u_h_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
		</cfif>
		</cfquery>
		<!--- check to see if a record has been found --->
		<cfif qryuser.recordcount EQ 0>
			<cfset theuser.notfound = "T">
<!--- 			<cflocation url="index.cfm?fa=c.logout&loginerror=T" /> --->
			<!--- <cfoutput>false</cfoutput> --->
		<cfelse>
			<cfset theuser.notfound = "F">
			<!--- Put the query result in the structure --->
			<cfset theuser.qryuser = qryuser>
			<!--- Set the Login into a session --->
			<cfset session.login = "T">
			<!--- Set the Web Login into a session --->
			<cfset session.weblogin = "F">
			<!--- Set the user ID into a session --->
			<cfset session.theuserid = "#qryuser.user_id#">
			<!--- Set User First and last name --->
			<cfset session.firstlastname = "#qryuser.user_first_name# #qryuser.user_last_name#">
			<!--- Admin Login: Set the domain ID into a session --->
			<cfif arguments.loginto EQ "admin">
				<cfset session.hostid = "0">
				<!--- Store the login info into cookie var --->
				<cfif arguments.rem_login EQ "T">
					<cfset SetCookie("loginnameadmin",arguments.name,"never")>
					<cfset SetCookie("loginpassadmin",thepass,"never")>
				<cfelse>
					<cfset SetCookie("loginnameadmin","","now")>
					<cfset SetCookie("loginpassadmin","","now")>
				</cfif>
				<!--- Cookie --->
				<cfset setcookie("loginadminrem",arguments.rem_login,"never")>
			</cfif>
			<!--- If we login to the DAM then check for the existence of the "My Folder" of this user --->
			<cfif arguments.loginto EQ "dam" AND arguments.from_share EQ "f">
				<!--- Store the login info into cookie var --->
				<cfif arguments.rem_login EQ "T">
					<cfset SetCookie("loginname",arguments.name,"never")>
					<cfset SetCookie("loginpass",thepass,"never")>
				<cfelse>
					<cfset SetCookie("loginname","","now")>
					<cfset SetCookie("loginpass","","now")>
				</cfif>
				<!--- Cookie --->
				<cfset setcookie("loginrem",arguments.rem_login,"never")>
				<cfset arguments.thestruct.dsn = application.razuna.datasource>
				<cfset arguments.thestruct.hostdbprefix = session.hostdbprefix>
				<cfset arguments.thestruct.database = application.razuna.thedatabase>
				<cfset arguments.thestruct.qryuser = qryuser>
				<cfset tt = CreateUUid()>
				<cfthread name="#tt#" intstruct="#arguments.thestruct#">
					<cfquery datasource="#attributes.intstruct.dsn#" name="myfolder">
					SELECT folder_of_user
					FROM #attributes.intstruct.hostdbprefix#folders
					WHERE folder_owner = <cfqueryparam value="#attributes.intstruct.qryuser.user_id#" cfsqltype="CF_SQL_VARCHAR">
					AND lower(folder_name) = <cfqueryparam value="my folder" cfsqltype="cf_sql_varchar">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
					<!--- Create the MY FOLDER for this user --->
					<cfif myfolder.recordcount EQ 0>
						<!--- Create ID --->
						<!--- <cfinvoke component="global" method="getsequence" returnvariable="newid" database="#attributes.intstruct.database#" dsn="#attributes.intstruct.dsn#" thetable="#session.hostdbprefix#folders" theid="folder_id"> --->
						<!--- Insert --->						
						<cfset newfolderid = replace(createuuid(),"-","","ALL")>
						<cfquery datasource="#attributes.intstruct.dsn#">
						INSERT INTO #attributes.intstruct.hostdbprefix#folders
						(folder_id, folder_name, folder_level, folder_owner, folder_create_date, folder_change_date, folder_create_time, folder_change_time, folder_of_user, folder_id_r, folder_main_id_r, host_id)
						values (
						<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="My Folder" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="1" cfsqltype="cf_sql_numeric">, 
						<cfqueryparam value="#attributes.intstruct.qryuser.user_id#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
						<cfqueryparam value="t" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
						</cfquery>
						<!--- Insert the DESCRIPTION --->
						<cfquery datasource="#attributes.intstruct.dsn#">
						insert into #attributes.intstruct.hostdbprefix#folders_desc
						(folder_id_r, lang_id_r, folder_desc, host_id)
						values(
						<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="1" cfsqltype="cf_sql_numeric">, 
						<cfqueryparam value="This is your personal folder" cfsqltype="cf_sql_varchar">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
						</cfquery>
					</cfif>
				</cfthread>
			</cfif>
<!--- 			<cflocation url="index.cfm?fa=c.main"> --->
			<!--- <cfoutput>true</cfoutput> --->
		</cfif>
		<cfreturn theuser />
	</cffunction>

<!--- FUNCTION: LOGINSTATUS --->
	<cffunction name="loginstatus" access="public" output="false" returntype="Any">
		<cfargument name="qry_sysadmingrp" type="query" required="true">
		<cfargument name="qry_admingrp" type="query" required="true">
		<cfargument name="qry_groups_user" type="query" required="true">
		<cfargument name="userid" type="string" required="true">
		<cfset status = structnew()>
		<cfset status.logedin = "F">
		<!--- Set in variables --->
		<cfset isSystemAdmin = ListFind(ValueList(arguments.qry_groups_user.grp_id), arguments.qry_sysadmingrp.grp_id)>
		<cfset isAdministrator = ListFind(ValueList(arguments.qry_groups_user.grp_id), arguments.qry_admingrp.grp_id)>
		<!--- Check that there is not the same user already inside. Hide this if the User is a Admin or SuperUser --->
		<cfif not isSystemAdmin AND not isAdministrator>
			<cfquery datasource="#variables.dsn#" name="sameuser">
			SELECT user_id
			FROM users_login
			WHERE user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.userid#">
			</cfquery>
			<!--- If there is the same user loged in already then log out --->
			<cfif sameuser.recordcount EQ 1>
				<cfset status.logedin = "T">
				<cfabort>
			</cfif>
		<!--- Check on the users hosts but only if the user is not systemadmin --->
		<cfelseif not isSystemAdmin>
			<cfset status.logedin = "F">
		</cfif>
		<cfreturn status>
	</cffunction>

	<!--- FUNCTION: SEND PASSWORD TO USER --->
	<cffunction name="sendpassword" displayname="sendpassword" hint="Sends password to user" access="public" output="true" returntype="Any">
		<cfargument name="email" required="yes" type="string">
		<!--- create structure to store results in --->
		<cfset thepass=structNew()>
		<!--- Check the email address of this user if there then send pass if not return to the form --->
		<cfquery datasource="#application.razuna.datasource#" name="qryuser">
		SELECT u.user_login_name, u.user_first_name, u.user_last_name, u.user_email, u.user_id
		FROM users u, ct_users_hosts ct
		WHERE (
			lower(u.user_email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#">
			OR lower(u.user_login_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#">
			)
		AND ct.ct_u_h_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
		AND ct.ct_u_h_user_id = u.user_id
		</cfquery>
		<!--- check to see if a record has been found --->
		<cfif qryuser.recordcount EQ 0>
			<cfset thepass.notfound = "T">
		<cfelse>
			<!--- User is found thus send him an email --->
			<cfset thepass.notfound = "F">
			<!--- Create Random Password --->
			<cfset var randompassword = randompass()>
			<!--- Hash Password --->
			<cfset newpass = hash(randompassword, "MD5", "UTF-8")>
			<!--- Update DB with new password --->
			<cfquery datasource="#variables.dsn#">
			UPDATE users
			SET user_pass = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newpass#">
			WHERE user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qryuser.user_id#">
			</cfquery>
			<!--- send email --->
			<cfmail from="do-not-reply@razuna.com" to="#qryuser.user_email#" subject="Your password for Razuna" type="text/plain">Hello #qryuser.user_first_name# #qryuser.user_last_name#

It looks like you have lost your password. We have generated a random password for you. You can now login with your username and/or email address and the password below.

Username: #qryuser.user_login_name#
Password: #randompassword#

			</cfmail>
		</cfif>
	<cfreturn thepass />
	</cffunction>

	<!--- FUNCTION: Random Password --->
	<cffunction name="randompass" access="public">
		<!--- Set up available lower case values. --->
		<cfset var Str_Lower_Case_Alpha = "abcdefghijklmnopqrstuvwxyz" />
		<!--- Set up available upper case values. This is done by converting the lower case string using "UCase". --->
		<cfset var Str_Upper_Case_Alpha = UCase( Str_Lower_Case_Alpha ) />
		<!--- Set up available numbers. --->
		<cfset var Str_Numbers = "0123456789" />
		<!--- Make a string that contains our lower case upper case and number values. --->
		<cfset var strAll = Str_Lower_Case_Alpha & Str_Upper_Case_Alpha & Str_Numbers />
		<!--- Create the password array of 1-3 dimensions. Index array elements with square brackets: [ ]. --->
		<cfset var arrPassword = ArrayNew( 1 ) />
		<!--- Generate the password and put each random value in the password array string. --->
		<!--- Select the random letter from our lower case set. --->
		<cfset arrPassword[ 1 ] = Mid(Str_Lower_Case_Alpha,RandRange( 1, Len( Str_Lower_Case_Alpha ) ), 1 ) />
		<!--- Select the random letter from our upper case set. --->
		<cfset arrPassword[ 2 ] = Mid(Str_Upper_Case_Alpha, RandRange( 1, Len( Str_Upper_Case_Alpha ) ), 1 ) />
		<!--- Select the random number from our number set. --->
		<cfset arrPassword[ 3 ] = Mid(Str_Numbers,RandRange( 1, Len( Str_Numbers ) ),1) />
		<!--- Create rest of the password. --->
		<cfset arrPassword[ 4 ] = Mid(strAll,RandRange( 1, Len( strAll ) ),1) />
		<cfset arrPassword[ 5 ] = Mid(strAll,RandRange( 1, Len( strAll ) ),1) />
		<cfset arrPassword[ 6 ] = Mid(strAll,RandRange( 1, Len( strAll ) ),1) />
		<cfset arrPassword[ 7 ] = Mid(strAll,RandRange( 1, Len( strAll ) ),1) />
		<cfset arrPassword[ 8 ] = Mid(strAll,RandRange( 1, Len( strAll ) ),1) />
		<!--- We don?t always want the first three characters to be of the same order (by type). --->
		<!--- Therefore, let's use the Java Collections utility class to shuffle this array into a "random" order. --->
		<cfset CreateObject( "java", "java.util.Collections" ).Shuffle(arrPassword ) />
		<!--- Join all the characters into a single string. --->
		<!--- We can do this by converting the array to a list and then just providing no delimiters (empty string delimiter). --->
		<cfset var strPassword = ArrayToList(arrPassword, "" ) />
		<!--- The password is finished. --->
		<!--- <cfoutput>#strPassword#</cfoutput> --->
		<!--- Return --->
		<cfreturn strPassword />
	</cffunction>
	
	<!--- FUNCTION: RazunaUpload SessionToken --->
	<cffunction name="razunauploadsession" access="public">
		<cfargument name="thestruct" required="yes" type="struct">
		<cfset var thetoken = replace(createuuid(),"-","","ALL")>
		<!--- Append to DB --->
		<cfquery datasource="#variables.dsn#">
		INSERT INTO webservices
		(sessiontoken, timeout, userid)
		VALUES(
		<cfqueryparam value="#thetoken#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#DateAdd("n", 30, now())#" cfsqltype="cf_sql_timestamp">,
		<cfqueryparam value="#arguments.thestruct.theuserid#" cfsqltype="CF_SQL_VARCHAR">
		)
		</cfquery>
		<!--- Get Host prefix --->
		<cfquery datasource="#variables.dsn#" name="pre">
		SELECT host_db_prefix
		FROM hosts
		WHERE host_id = <cfqueryparam value="#arguments.thestruct.hostid#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<!--- Return --->
		<cfreturn thetoken>
	</cffunction>
	
	<!--- FUNCTION: Request Access eMail --->
	<cffunction name="reqaccessemail" access="public">
		<cfargument name="thestruct" required="yes" type="struct">
		<!--- Get admins --->
		<cfinvoke component="global.cfc.groups_users" method="getadmins" returnvariable="theadmins">
		<cfloop query="theadmins">
			<cfinvoke component="email" method="send_email" to="#user_email#" subject="Razuna: User requests access" themessage="The user #arguments.thestruct.user_first_name# #arguments.thestruct.user_last_name# (#arguments.thestruct.user_email#) is requesting access to your Razuna. You should go to the Razuna Administration and grant or deny this user access now!">
		</cfloop>
	</cffunction>
	
	<!--- Check user and host. This is if login form is only the email and pass --->
	<cffunction name="checkhost" access="public">
		<cfargument name="thestruct" required="yes" type="struct">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="theuser" cachename="loginhost#session.hostid##arguments.thestruct.theemail#" cachedomain="#session.hostid#_users">
		SELECT h.host_name, h.host_name_custom, h.host_id
		FROM users u, ct_users_hosts ct, hosts h
		WHERE (
			lower(u.user_login_name) = <cfqueryparam value="#lcase(arguments.thestruct.theemail)#" cfsqltype="cf_sql_varchar"> 
			OR lower(u.user_email) = <cfqueryparam value="#lcase(arguments.thestruct.theemail)#" cfsqltype="cf_sql_varchar">
		)
		AND lower(u.user_active) = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="t">
		AND u.user_id = ct.ct_u_h_user_id
		<cfif structkeyexists(session,"hostid")>
			AND h.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
			AND ct.ct_u_h_host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
		<cfelse>
			AND h.host_id = ct.ct_u_h_host_id
			AND ct.ct_u_h_host_id = h.host_id
		</cfif>
		</cfquery>
		<!--- Do we have one domain --->
		<cfif theuser.recordcount EQ 1>
			<!--- Set session hostid --->
			<cfset session.hostid = theuser.host_id>
			<!--- Now do the login. Function on top --->
			<cfinvoke method="login" returnVariable="thelogin">
				<cfinvokeargument name="name" value="#arguments.thestruct.theemail#">
				<cfinvokeargument name="pass" value="#arguments.thestruct.pass#">
				<cfinvokeargument name="loginto" value="dam">
				<cfinvokeargument name="rem_login" value="#arguments.thestruct.rem_login#">
			</cfinvoke>
			<!--- If the login returns true we let user in --->
			<cfif thelogin.notfound EQ "f">
				<cflocation url="index.cfm?fa=c.mini_browser">
			<cfelse>
				<cflocation url="index.cfm?fa=c.mini&e=t">
			</cfif>
		<cfelse>
			<cflocation url="index.cfm?fa=c.mini&e=t">
		
			
		</cfif>
	</cffunction>
	
</cfcomponent>