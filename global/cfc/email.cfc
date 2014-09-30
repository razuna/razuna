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

<!---  CHECK THE EMAIL AND RETRIEVE THE ATTACHMENT JUST FOR THE VIEW ------------------------------>
<cffunction name="emailheaders" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = structnew()>
	<cftry>
	<!--- Check the account for email messages (return when connection error) --->
		<cfpop action="getheaderonly" server="#arguments.thestruct.email_server#" username="#arguments.thestruct.email_address#" password="#arguments.thestruct.email_pass#" name="qryemailheaders" timeout="300">
		<!--- create new Query --->
		<cfset qryHeaders = queryNew(qryEmailHeaders.columnList)>
		<!--- set the appropriate records into the new query --->
		<cfloop query="qryemailheaders">
			<cfif #findNoCase(arguments.thestruct.email_subject, subject)# GT 0>
				<cfset tmp = QueryAddRow(qryHeaders,1)>
				<cfloop list="#columnList#" index="column">
					<cfset tmp = querySetCell(qryHeaders, column, qryemailheaders[column][currentrow])>
				</cfloop>
			</cfif>
		</cfloop>
		<cfset qry.qryheaders = qryheaders>
		<cfset qry.error = "F">
	<cfcatch type="any">
		<cfset qry.error = cfcatch.detail>
	</cfcatch>
	</cftry>
	<cfreturn qry>
</cffunction>

<!--- GET THE MESSAGE FOR THE DETAIL VIEW --->
<cffunction hint="get the message for the detail view" name="emailmessage" output="false">
	<cfargument name="themessageid" default="" required="yes" type="numeric">
	<cfargument name="thepathhere" default="" required="yes" type="string">
	<cfpop action="getall" server="#session.email_server#" username="#session.email_address#" password="#session.email_pass#" name="qrymessage" messagenumber="#arguments.themessageid#" attachmentpath="#arguments.thepathhere#/incoming/emails" generateuniquefilenames="no" timeout="3600">
	<cfreturn qrymessage>
</cffunction>

<!--- REMOVE THE MESSAGE --->
<cffunction hint="remove the message" name="removemessage" output="false">
	<cfargument name="themessageid" default="" required="yes" type="numeric">
	<cfpop action="delete" server="#session.email_server#" username="#session.email_address#" password="#session.email_pass#" messagenumber="#arguments.themessageid#">
	<cfreturn />
</cffunction>

<!--- GLOBAL SENDEMAIL --->
<cffunction hint="global sendemail" name="send_email" output="false" access="remote" returnType="void">
	<cfargument name="to" default="" required="no" type="string">
	<cfargument name="cc" default="" required="no" type="string">
	<cfargument name="bcc" default="" required="no" type="string">
	<cfargument name="from" default="" required="no" type="string">
	<cfargument name="subject" default="" required="no" type="string">
	<cfargument name="attach" default="" required="no" type="string">
	<cfargument name="themessage" default="" required="no" type="string">
	<cfargument name="thepath" default="" required="no" type="string">
	<cfargument name="sendaszip" default="F" required="no" type="string">
	<cfargument name="dsn" default="" required="no" type="string">
	<cfargument name="hostdbprefix" default="" required="no" type="string">
	<cfargument name="userid" default="" required="no" type="string">
	<cfargument name="hostid" default="" required="no" type="string">
	<cftry>
		<!--- Set data source since this call could also come from RFS --->
		<cfif arguments.dsn EQ "">
			<cfset var thedsn = application.razuna.datasource>
		<cfelse>
			<cfset var thedsn = arguments.dsn>
		</cfif>
		<!--- Set data source since this call could also come from RFS --->
		<cfif arguments.hostdbprefix EQ "">
			<cfset var thehostdbprefix = session.hostdbprefix>
		<cfelse>
			<cfset var thehostdbprefix = arguments.hostdbprefix>
		</cfif>
		<!--- Set data source since this call could also come from RFS --->
		<cfif arguments.hostid EQ "">
			<cfset var thehostid = session.hostid>
		<cfelse>
			<cfset var thehostid = arguments.hostid>
		</cfif>
		<!--- Set data source since this call could also come from RFS --->
		<cfif arguments.userid EQ "">
			<cfset var theuserid = session.theuserid>
		<cfelse>
			<cfset var theuserid = arguments.userid>
		</cfif>
		<!--- Query email settings --->
		<cfquery datasource="#thedsn#" name="emaildata">
		SELECT set2_email_server, set2_email_from, set2_email_smtp_user, set2_email_smtp_password, set2_email_server_port, set2_email_use_ssl, set2_email_use_tls, set2_intranet_reg_emails, set2_intranet_reg_emails_sub,
		set2_duplicates_email_sub, set2_duplicates_email_body, set2_duplicates_meta 
		FROM #thehostdbprefix#settings_2
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#thehostid#">
		</cfquery>
		<cfif isdefined("isdup")>
			<!--- Find duplicate records found in the Razuna system and record it in the log --->
			<!--- Images --->
			<cfinvoke component="images" method="checkmd5" md5hash="#md5hash#" returnvariable="qryimg" />
			<!--- videos --->
			<cfinvoke component="videos" method="checkmd5" md5hash="#md5hash#" returnvariable="qryvid" />
			<!--- Files --->
			<cfinvoke component="files" method="checkmd5" md5hash="#md5hash#" returnvariable="qrydoc" />
			<!--- Audios --->
			<cfinvoke component="audios" method="checkmd5" md5hash="#md5hash#" returnvariable="qryaud" />

			<cfif qryimg.recordcount NEQ 0>
				<cfset var dataqry = "qryimg">
			<cfelseif qryvid.recordcount NEQ 0>
				<cfset var dataqry = "qryvid">
			<cfelseif qryaud.recordcount NEQ 0>
				<cfset var dataqry = "qryaud">
			<cfelseif qrydoc.recordcount NEQ 0>
				<cfset var dataqry = "qrydoc">
			<cfelse>
				<cfset var dataqry = "qryimg">
			</cfif>
			<cfquery dbtype="query" name="getdups">
				SELECT * FROM #dataqry#
			</cfquery>
			<!--- Get duplicate file names and path --->
			<cfset var duplist = "">
			<cfloop query="getdups">
				<cfset var folders = "">
				<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#getdups.folder_id_r#" returnvariable="crumbs" />
				<cfloop list="#crumbs#" delimiters=";" index="i">
					<cfset folders = folders & "/#ListGetAt(i,1,"|")#">
				</cfloop>
				<cfset folders = folders & "/#getdups.name#<br/>">
				<cfset duplist = duplist & folders>
			</cfloop>

			<cfif emaildata.set2_duplicates_email_sub NEQ "">
				<cfset arguments.subject = replacenocase (emaildata.set2_duplicates_email_sub,"$filename$",arguments.filename,"ALL")>
			</cfif>
			<cfif len(emaildata.set2_duplicates_email_body) GT 10>
				<cfset arguments.themessage = replacenocase (emaildata.set2_duplicates_email_body,"$filename$",arguments.filename,"ALL")>
				<cfset arguments.themessage = replacenocase (arguments.themessage,"$location$",duplist,"ALL")>
			</cfif>
		</cfif>

		<!--- If the to is empty --->
		<cfif arguments.to EQ "">
			<cfquery datasource="#thedsn#" name="qryuser">
			SELECT user_email
			FROM users
			WHERE user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theuserid#">
			</cfquery>
			<cfset arguments.to = qryuser.user_email>
		</cfif>
		<!--- The to is empty, so simply skip sending the eMail --->
		<cfif arguments.to NEQ "">
			<!--- Always take the email address from the settings if not specified in arguments --->
			<cfif arguments.from NEQ ''>
				<cfset var thefrom = arguments.from>
			<cfelse>
				<cfset var thefrom = emaildata.set2_email_from>
			</cfif>
			
			<!--- send message if mail server setting is empty thus take the CF admin settings--->
			<cfif emaildata.set2_email_server EQ "">
				<cfmail to="#arguments.to#" cc="#arguments.cc#" bcc="#arguments.bcc#" from="#thefrom#" subject="#arguments.subject#" type="text/html"><cfif #arguments.themessage# IS NOT "">#arguments.themessage#</cfif>
					<cfif arguments.sendaszip EQ "T">
						<!--- Check the attachment (zip or normal files) --->
						<cfif right("#arguments.attach#", 4) EQ ".zip">
							<cfmailparam file="#arguments.thepath#/outgoing/#arguments.attach#">
						<cfelse>
							<!--- Check if folder or normal file (in the case of unzipped documents) --->
							<cfif DirectoryExists(arguments.attach)>
								<!--- Read the temp directory --->
								<cfdirectory directory="#arguments.attach#" action="list" recurse="true" name="dirQuery" type="file">
								<!--- Loop over directory list --->
								<cfloop query="dirQuery">
									<cfset var newFileName = "#ListLast(dirQuery.directory,'/\')#_#dirQuery.name#">
									<cffile action="rename" source="#dirQuery.directory#/#dirQuery.name#" destination="#newFileName#">
									<cfmailparam file="#dirQuery.directory#/#newFileName#">
								</cfloop>
							<cfelse>
								<!--- Handle normal doc files --->
								<cfmailparam file="#arguments.thepath#/outgoing/#arguments.attach#">
							</cfif>
						</cfif>
					</cfif>
				</cfmail>
			<cfelse>
				<!--- send message if there is a mail server set for this host --->
				<cfmail to="#arguments.to#" cc="#arguments.cc#" bcc="#arguments.bcc#" from="#thefrom#" subject="#arguments.subject#" username="#emaildata.SET2_EMAIL_SMTP_USER#" password="#emaildata.SET2_EMAIL_SMTP_PASSWORD#" server="#emaildata.SET2_EMAIL_SERVER#" port="#emaildata.SET2_EMAIL_SERVER_PORT#" usessl="#emaildata.SET2_EMAIL_USE_SSL#" usetls="#emaildata.SET2_EMAIL_USE_TLS#" type="text/html" timeout="900"><cfif #arguments.themessage# IS NOT "">#arguments.themessage#</cfif>
					<cfif arguments.sendaszip EQ "T">
						<!--- Check the attachment (zip or normal files) --->
						<cfif right("#arguments.attach#", 4) EQ ".zip">
							<cfmailparam file="#arguments.thepath#/outgoing/#arguments.attach#">
						<cfelse>
							<!--- Check if folder or normal file (in the case of unzipped documents) --->
							<cfif DirectoryExists(arguments.attach)>
								<!--- Read the temp directory --->
								<cfdirectory directory="#arguments.thepath#/outgoing/#arguments.attach#" action="list" recurse="true" name="dirQuery" type="file">
								<!--- Loop over directory list --->
								<cfloop query="dirQuery">
									<cfset var newFileName = "#ListLast(dirQuery.directory,'/\')#_#dirQuery.name#">
									<cffile action="rename" source="#dirQuery.directory#/#dirQuery.name#" destination="#newFileName#">
									<cfmailparam file="#dirQuery.directory#/#newFileName#">
								</cfloop>
							<cfelse>
								<!--- Handle normal doc files --->
								<cfmailparam file="#arguments.thepath#/outgoing/#arguments.attach#">
							</cfif>
						</cfif>
					</cfif>
				</cfmail>
			</cfif>
		</cfif>
		<cfcatch type="any">
			<cfmail from="server@razuna.com" to="support@razuna.com" subject="error in sending eMail" type="html">
				<cfdump var="#arguments#">
				<cfdump var="#cfcatch#">
			</cfmail>
		</cfcatch>
	</cftry>
</cffunction>

<!--- Send Password --->
<cffunction name="sendpassword">
	<cfargument name="thestruct" type="Struct">
	<!--- Get translations --->
	<cfinvoke component="defaults" method="trans" transid="email_pass_subject" returnvariable="thesubject" />
	<cfinvoke component="defaults" method="trans" transid="email_pass_body" returnvariable="thebody" />
	<!--- Replace subject with values --->
	<cfset thesubject = replacenocase(thesubject,"--url--","#arguments.thestruct.siteurl#","ALL")>
	<!--- Replace the body tags with values --->
	<cfset thebody = replacenocase(thebody,"--firstname--","#arguments.thestruct.qryuser.user_first_name#","ALL")>
	<cfset thebody = replacenocase(thebody,"--lastname--","#arguments.thestruct.qryuser.user_last_name#","ALL")>
	<cfset thebody = replacenocase(thebody,"--newpassword--","kab108zun","ALL")>
	<cfset thebody = replacenocase(thebody,"--url--","#arguments.thestruct.siteurl#","ALL")>
	<!--- Send the email --->
	<cfinvoke method="send_email" to="#arguments.thestruct.qryuser.user_email#" subject="#thesubject#" themessage="#thebody#" />
</cffunction>

</cfcomponent>
