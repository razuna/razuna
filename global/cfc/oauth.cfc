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
	
	<!--- Authenticate --->
	<cffunction name="authenticate" output="true" access="remote">
		<cfargument name="account" type="string" required="true">
		<!--- Get request token --->
		<cfset getRequestToken(arguments.account)>
		<!--- Now redirect user to authenticate for Razuna --->
		<cfif arguments.account EQ "dropbox">
			<cflocation url="https://www.dropbox.com/1/oauth/authorize?oauth_token=#session.oauth_token#&oauth_callback=#urlencodedformat("#session.thehttp##cgi.http_host##cgi.script_name#?fa=c.oauth_authenticate_return&account=#arguments.account#")#">
		</cfif>
		<cfreturn />	
	</cffunction>

	<!--- Return from Authenticate --->
	<cffunction name="authenticate_return" output="true" access="public">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Fail if uid is not in struct --->
		<cfif !structKeyExists(arguments.thestruct, "uid")>
			<cfoutput><span style="font-weight:bold;color:red;">We are unable to get an authentication!</span><br /><br /><a href="##" onclick="window.close();">Close this window</a></cfoutput>
		<!--- User allows thus continue --->
		<cfelse>
			<cftry>
				<!--- Call again to turn request_token into access_token --->
				<cfhttp method="post" url="#application.razuna["#arguments.thestruct.account#"].url_api#/oauth/access_token">
					<cfhttpparam type="formfield" name="oauth_version" value="1.0"/>
					<cfhttpparam type="formfield" name="oauth_signature_method" value="PLAINTEXT"/>
					<cfhttpparam type="formfield" name="oauth_consumer_key" value="#session["#arguments.thestruct.account#"].appkey#"/>
					<cfhttpparam type="formfield" name="oauth_token" value="#session.oauth_token#"/>
					<cfhttpparam type="formfield" name="oauth_signature" value="#session["#arguments.thestruct.account#"].appsecret#&#session.oauth_token_secret#"/>
				</cfhttp>
				<!--- We get back the access tokens like oauth_token_secret=56o72oyoehzw8iq&oauth_token=jeost6cz9chka8s&uid=20724584 --->
				<!--- Put return into var --->
				<cfset var tokens = trim(cfhttp.filecontent.toString())>
				<!--- Delete any entry that might be in settings db already for this account --->
				<cfquery datasource="#application.razuna.datasource#">
				DELETE FROM #session.hostdbprefix#settings
				WHERE lower(set_id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.account)#_%">
				AND host_id = <cfqueryparam value="#session.hostid#" CFSQLType="CF_SQL_NUMERIC">
				</cfquery>
				<!--- Loop over tokens --->
				<cfloop list="#tokens#" delimiters="&" index="i">
					<cfset n = listFirst(i,"=")>
					<cfset v = listLast(i,"=")>
					<!--- Add the account type to the var name --->
					<cfset nid = "#arguments.thestruct.account#_#n#">
					<!--- Append to DB --->
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#settings
					(set_id, set_pref, host_id, rec_uuid)
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#nid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#v#">,
						<cfqueryparam value="#session.hostid#" CFSQLType="CF_SQL_NUMERIC">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">
					)
					</cfquery>
				</cfloop>
				<cfoutput>
					<span style="font-weight:bold;color:green;">We successfully connected to your account!</span><br /><br /><a href="##" onclick="window.close();">You can close this window now.</a>
					<script type="text/javascript">
						// Update divs
						var req = new XMLHttpRequest();
						var requp = new XMLHttpRequest();
						var reqexp = new XMLHttpRequest();
						req.open("GET", "index.cfm?fa=c.admin_integration", false);
						requp.open("GET", "index.cfm?fa=c.smart_folders_update&sf_id=0&sf_type=#arguments.thestruct.account#&sf_name=#ucase(arguments.thestruct.account)#", false);
						reqexp.open("GET", "index.cfm?fa=c.smart_folders", false);
						req.send(null);
						requp.send(null);
						reqexp.send(null);
						var page = req.responseText;
						var pageup = requp.responseText;
						var pageexp = reqexp.responseText;
						window.opener.document.getElementById('admin_integration').innerHTML = page;
						window.opener.document.getElementById('div_forall').innerHTML = pageup;
						window.opener.document.getElementById('explorer').innerHTML = pageexp;
						window.opener.document.getElementById('mainsectionchooser').text = 'Smart Folders';
					</script>
				</cfoutput>
				<!--- Catch --->
				<cfcatch type="any">
					<span style="font-weight:bold;color:red;">Oops an error occured: #cfcatch.message# - #cfcatch.detail#</span>
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>

	<!--- Get Request Token --->
	<cffunction name="getRequestToken" output="true" access="private" returntype="void">
		<cfargument name="account" type="string" required="true">
		<!--- Get request token --->
		<cfhttp method="post" url="#application.razuna["#arguments.account#"].url_api#/oauth/request_token">
			<cfhttpparam type="formfield" name="oauth_version" value="1.0"/>
			<cfhttpparam type="formfield" name="oauth_signature_method" value="PLAINTEXT"/>
			<cfhttpparam type="formfield" name="oauth_consumer_key" value="#session["#arguments.account#"].appkey#"/>
			<cfhttpparam type="formfield" name="oauth_signature" value="#session["#arguments.account#"].appsecret#&"/>
		</cfhttp>
		<!--- Put return into var --->
		<cfset var tokens = trim(cfhttp.filecontent.toString())>
		<!--- Above will return oauth_token=<request-token>&oauth_token_secret=<request-token-secret> --->
		<cfloop list="#tokens#" delimiters="&" index="i">
			<cfset n = listFirst(i,"=")>
			<cfset v = listLast(i,"=")>
			<!--- Set variable --->
			<cfset "session.#n#" = v>
		</cfloop>
		<cfreturn />	
	</cffunction>

	<!--- Remove --->
	<cffunction name="remove" output="false" access="Public" returntype="void">
		<cfargument name="account" type="string" required="true">
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#settings
		WHERE lower(set_id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.account)#_%">
		AND host_id = <cfqueryparam value="#session.hostid#" CFSQLType="CF_SQL_NUMERIC">
		</cfquery>
		<cfreturn />
	</cffunction>

	<!--- Remove --->
	<cffunction name="check" output="false" access="Public" returntype="query">
		<cfargument name="account" type="string" required="true">
		<!--- Param --->
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT set_id, set_pref
		FROM #session.hostdbprefix#settings
		WHERE lower(set_id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.account)#_%">
		AND host_id = <cfqueryparam value="#session.hostid#" CFSQLType="CF_SQL_NUMERIC">
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Remove --->
	<cffunction name="getstoredtokens" output="false" access="Public" returntype="void">
		<cfargument name="account" type="string" required="true">
		<!--- Param --->
		<cfset var setid = "">
		<cfparam name="session['#arguments.account#']" default="#structnew()#" />
		<!--- Get app keys --->
		<cfif !structKeyExists(session["#arguments.account#"],"appkey")>
			<cfinvoke component="settings" method="getappkey" account="#arguments.account#" />
		</cfif>
		<!--- Set token keys --->
		<cfif !structKeyExists(session["#arguments.account#"],"oauth_token")>
			<!--- Query --->
			<cfset var tokens = check(arguments.account)>
			<!--- Loop over and store in session scope --->
			<cfloop query="tokens">
				<!--- Replace account in setid --->
				<cfset setid = replacenocase(set_id,"#arguments.account#_","","one")>
				<!--- Set session in account scope --->
				<cfset session["#arguments.account#"]["#setid#"] = set_pref>
			</cfloop>
		</cfif>
		<!--- Return --->
		<cfreturn />
	</cffunction>

</cfcomponent>