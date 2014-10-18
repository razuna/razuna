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
<cfcomponent output="false" namespace="user" extends="authentication">

	<!--- Add the user --->
	<cffunction name="add" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="user_first_name" type="string" required="true">
		<cfargument name="user_last_name" type="string" required="true">
		<cfargument name="user_email" type="string" required="true">
		<cfargument name="user_name" type="string" required="true">
		<cfargument name="user_pass" type="string" required="true">
		<cfargument name="user_active" type="string" required="false" default="f">
		<cfargument name="groupid" type="string" required="false" default="0">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Check that we don't have the same user --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry_sameuser">
				SELECT users.user_email, users.user_login_name, user_id
				FROM users, ct_users_hosts
				WHERE (
					lower(users.user_email) = <cfqueryparam value="#lcase(arguments.user_email)#" cfsqltype="cf_sql_varchar">
					OR lower(users.user_login_name) = <cfqueryparam value="#lcase(arguments.user_name)#" cfsqltype="cf_sql_varchar">
					)
				AND ct_users_hosts.ct_u_h_host_id = #application.razuna.api.hostid["#arguments.api_key#"]#
				</cfquery>
				<!--- If user does not exist do the insert --->
				<cfif qry_sameuser.recordcount EQ 0>
					<!--- Create new ID --->
					<cfset newuserid = createuuid()>
					<!--- Hash Password --->
					<cfset thepass = hash(arguments.user_pass, "MD5", "UTF-8")>
					<!--- Insert the User into the DB --->
					<cfquery datasource="#application.razuna.api.dsn#">
					INSERT INTO users
					(user_id, user_login_name, user_email, user_pass, user_first_name, user_last_name, user_in_admin,
					user_create_date, user_active, user_in_dam)
					VALUES(
					<cfqueryparam value="#newuserid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.user_name#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user_email#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#thepass#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user_first_name#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user_last_name#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="F" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#arguments.user_active#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="T" cfsqltype="cf_sql_varchar">
					)
					</cfquery>
					<!--- Insert the user to the user host cross table --->
					<cfquery datasource="#application.razuna.api.dsn#">
					INSERT INTO ct_users_hosts
					(ct_u_h_user_id, ct_u_h_host_id, rec_uuid)
					VALUES(
					<cfqueryparam value="#newuserid#" cfsqltype="CF_SQL_VARCHAR">,
					#application.razuna.api.hostid["#arguments.api_key#"]#,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
					<!--- Insert into group --->
					<cfif arguments.groupid NEQ 0>
						<cfif arguments.groupid NEQ 1>
							<cfquery datasource="#application.razuna.api.dsn#">
							INSERT INTO	ct_groups_users
							(ct_g_u_grp_id, ct_g_u_user_id, rec_uuid)
							VALUES(
							<cfqueryparam value="#arguments.groupid#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#newuserid#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">
							)
							</cfquery>
							<!--- Check group folder_subscribe setting and add this user to receive folder notifications if set to true --->
							<cfinvoke component="global.cfc.groups" method="add_grp_users2notify" group_id='#arguments.groupid#' user_id='#newuserid#'>
						</cfif>
						<!--- If the groupid is 2 --->
						<cfif arguments.groupid EQ 2>
							<cfset thexml.apikey = createuuid("")>
							<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE users
							SET user_api_key = <cfqueryparam value="#thexml.apikey#" cfsqltype="CF_SQL_VARCHAR">
							WHERE user_id = <cfqueryparam value="#newuserid#" cfsqltype="CF_SQL_VARCHAR">
							</cfquery>
						</cfif>
					</cfif>
					<!--- Flush cache --->
					<cfset resetcachetoken(arguments.api_key,"users")>
					<!--- Response --->
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "User has been added successfully">
					<cfset thexml.userid = newuserid>
				<!--- User exist thus fail message --->
				<cfelse>
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "User already exists">
					<cfset thexml.userid = qry_sameuser.user_id>
				</cfif>
			<!--- User not admin --->
			<cfelse>
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>

	<!--- Get this user information --->
	<cffunction name="getuser" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get Cachetoken --->
			<cfset var cachetoken = getcachetoken(arguments.api_key,"users")>
			<!--- Query the user --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml" cachedwithin="1" region="razcache">
			SELECT /* #cachetoken#getuser */ user_id, user_login_name, user_email, user_first_name, user_last_name, user_api_key
			FROM users
			WHERE user_id = <cfqueryparam value="#application.razuna.api.userid["#arguments.api_key#"]#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- If user does not exist do the insert --->
			<cfif qry.recordcount EQ 0>
				<cfset thexml = querynew("responsecode,message")>
				<cfset queryaddrow(thexml,1)>
				<cfset querysetcell(thexml,"responsecode","1")>
				<cfset querysetcell(thexml,"message","User with the ID could not be found")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Update user --->
	<cffunction name="update" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="userid" required="false" type="string" default="">
		<cfargument name="userloginname" required="false" type="string" default="">
		<cfargument name="useremail" required="false" type="string" default="">
		<cfargument name="userdata" required="true" type="string" hint="JSON with fields to update">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Query the user --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT user_id
				FROM users
				<cfif arguments.userid NEQ "">
					WHERE user_id = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_VARCHAR">
				<cfelseif arguments.userloginname NEQ "">
					WHERE lower(user_login_name) = <cfqueryparam value="#lcase(arguments.userloginname)#" cfsqltype="CF_SQL_VARCHAR">
				<cfelseif arguments.useremail NEQ "">
					WHERE lower(user_email) = <cfqueryparam value="#lcase(arguments.useremail)#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					WHERE user_email = <cfqueryparam value="nada" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				</cfquery>
				<!--- User found --->
				<cfif qry.recordcount EQ 1>
					<!--- deserializeJSON back into array --->
					<cfset var thejson = DeserializeJSON(arguments.userdata)>
					<cfset var l = "">
					<!--- Loop over JSON and update data --->
					<cfloop index="x" from="1" to="#arrayLen(thejson)#">
						<cfset l = l & "," & #thejson[x][1]#>
						<!--- Just user fields --->
						<cfif #thejson[x][1]# CONTAINS "user_">
							<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE users
							SET #thejson[x][1]# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thejson[x][2]#">
							WHERE user_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#qry.user_id#">
							</cfquery>
						</cfif>
					</cfloop>
					<!--- Do the group update --->
					<!--- Does a key exists --->
					<cfif listcontains(l,"group_id") NEQ 0>
						<!--- There is a group_id remove all existing groups --->
						<cfquery datasource="#application.razuna.api.dsn#">
						DELETE FROM ct_groups_users
						WHERE ct_g_u_user_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#qry.user_id#">
						</cfquery>
						<!--- Loop over json and insert group --->
						<cfloop index="x" from="1" to="#arrayLen(thejson)#">
							<!--- Just user fields --->
							<cfif #thejson[x][1]# CONTAINS "group_id">
								<cfquery datasource="#application.razuna.api.dsn#">
								INSERT INTO ct_groups_users
								(ct_g_u_grp_id, ct_g_u_user_id, rec_uuid)
								VALUES(
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thejson[x][2]#">,
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#qry.user_id#">,
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
								)
								</cfquery>
								<!--- Check group 'folder_subscribe' setting and add this user to receive folder notifications if set to true --->
								<cfinvoke component="global.cfc.groups" method="add_grp_users2notify" group_id='#thejson[x][2]#' user_id='#qry.user_id#'>
							</cfif>
						</cfloop>
					</cfif>
					<!--- Flush cache --->
					<cfset resetcachetoken(arguments.api_key,"users")>
					<!--- Response --->
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "User has been updated successfully">
					<cfset thexml.userid = qry.user_id>
				<!--- NOT found --->
				<cfelse>
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "User with the ID could not be found">
				</cfif>
			<!--- User not admin --->
			<cfelse>
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Delete user --->
	<cffunction name="delete" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="userid" required="false" type="string" default="">
		<cfargument name="userloginname" required="false" type="string" default="">
		<cfargument name="useremail" required="false" type="string" default="">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Query the user --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT user_id
				FROM users
				<cfif arguments.userid NEQ "">
					WHERE user_id = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_VARCHAR">
				<cfelseif arguments.userloginname NEQ "">
					WHERE lower(user_login_name) = <cfqueryparam value="#lcase(arguments.userloginname)#" cfsqltype="CF_SQL_VARCHAR">
				<cfelseif arguments.useremail NEQ "">
					WHERE lower(user_email) = <cfqueryparam value="#lcase(arguments.useremail)#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					WHERE user_email = <cfqueryparam value="nada" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				</cfquery>
				<!--- User found --->
				<cfif qry.recordcount EQ 1>
					<cfquery datasource="#application.razuna.api.dsn#">
					DELETE FROM ct_users_hosts
					WHERE ct_u_h_user_id = <cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<!--- Remove Intra/extranet carts  --->
					<cfquery datasource="#application.razuna.api.dsn#">
					DELETE FROM #application.razuna.api.prefix["#arguments.api_key#"]#cart
					WHERE user_id = <cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					</cfquery>
					<!--- Remove user comments  --->
					<cfquery datasource="#application.razuna.api.dsn#">
					DELETE FROM users_comments
					WHERE user_id_r = <cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<!--- Remove from the User Table --->
					<cfquery datasource="#application.razuna.api.dsn#">
					DELETE FROM users
					WHERE user_id = <cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<!--- Flush cache --->
					<cfset resetcachetoken(arguments.api_key,"users")>
					<!--- Response --->
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "User has been removed successfully">
					<cfset thexml.userid = qry.user_id>
				<!--- NOT found --->
				<cfelse>
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "User with the ID could not be found">
				</cfif>
			<!--- User not admin --->
			<cfelse>
				<cfset var thexml = noaccess("s")>
			</cfif>
			<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>

	<!--- SSO --->
	<cffunction name="saml_sso" access="remote" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="SAMLResponse" required="true" type="string">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<cfset var qry_isp = "">
		<cfset var prefs = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<cftry>
				<!--- Decode encoded XML --->
				<cfset var xmlResponse=CharsetEncode(BinaryDecode(Replace(StripCR(arguments.SAMLResponse),"#chr(10)#", "", "ALL"),"Base64"),"utf-8")>
				<!--- If not XML found then abort --->
				<cfif !isxml(xmlResponse)>
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "Invalid XML">
					<cfreturn thexml>
				</cfif>
				<!--- Parse XML --->
				<cfset var xmlparsed = xmlparse(xmlresponse)>
				<cfinvoke component="global.cfc.settings" method="getsettingsfromdam" returnvariable="prefs">
				<!--- Check xmlpath to email is entered, required field--->
				<cfif prefs.set2_saml_xmlpath_email EQ ''>
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "XML path for email not defined.">
					<cfreturn thexml>
				</cfif>
				<!--- Get email from XML based on XMLsearch criterion --->
				<cfset var user_email = xmlsearch(xmlparsed, "#prefs.set2_saml_xmlpath_email#")>
				<cfset user_email = user_email[1].xmltext>
				<!--- Check if xmlpath to password specified, optional field --->
				<cfif prefs.set2_saml_xmlpath_password NEQ ''>
					<cfset var user_password = xmlsearch(xmlparsed, "#prefs.set2_saml_xmlpath_password#")>
					<cfset user_password = user_password[1].xmltext>
					<!--- Hash password --->
					<cfset user_password = hash(user_password, "MD5", "UTF-8")>
				</cfif>
			<cfcatch>
				<cfset thexml.responsecode = 1>
				<cfset thexml.message = "Error occured trying to decode XML: #cfcatch.message#">
				<cfreturn thexml>
			</cfcatch>
			</cftry>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Query the user --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT u.user_email, u.user_login_name, u.user_id, u.user_pass
				FROM users u, ct_users_hosts ct
				WHERE (
					lower(u.user_email) = <cfqueryparam value="#lcase(user_email)#" cfsqltype="cf_sql_varchar">
					OR lower(u.user_login_name) = <cfqueryparam value="#lcase(user_email)#" cfsqltype="cf_sql_varchar">
					)
				AND ct.ct_u_h_host_id = #application.razuna.api.hostid["#arguments.api_key#"]#
				AND ct.ct_u_h_user_id = u.user_id
				<cfif isdefined("user_password")>
					AND u.user_pass = <cfqueryparam value="#user_password#" cfsqltype="cf_sql_varchar">
				</cfif>
				</cfquery>
				<!--- User found --->
				<cfif qry.recordcount NEQ 0>
					<!--- Check if this is for hosted --->
					<cfquery datasource="#application.razuna.api.dsn#" name="qry_isp">
					SELECT opt_value
					FROM options
					WHERE lower(opt_id) = <cfqueryparam value="conf_isp" cfsqltype="cf_sql_varchar">
					</cfquery>
					<!--- If for hosted --->
					<cfif qry_isp.opt_value>
						<cfset var the_url = "/index.cfm?fa=c.dologin&tl=true&pass=" & qry.user_pass & "&name=" & user_email & "&pass_hashed=true">
					<cfelse>
						<cfset var the_url = "/" & cgi.context_path & "/" & application.razuna.api.hostpath["#arguments.api_key#"] & "/dam/index.cfm?fa=c.dologin&tl=true&pass=" & qry.user_pass & "&name=" & user_email & "&pass_hashed=true">
					</cfif>
					<!--- For non hosted --->
					<cflocation url="//#cgi.http_host#/#the_url#" addtoken="yes" />
				<!--- NOT found --->
				<cfelse>
					<!--- Check if redirect specified on fail, optional field --->
					<cfif prefs.set2_saml_httpredirect contains 'http'>
						<cflocation url="#prefs.set2_saml_httpredirect #" addtoken="yes" />
					<cfelse>
						<cfset thexml.responsecode = 1>
						<cfset thexml.message = "User with email #user_email# not found">
					</cfif>
				</cfif>
			<!--- User not admin --->
			<cfelse>
				<cfset var thexml = noaccess("s")>
			</cfif>
			<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
		
</cfcomponent>
