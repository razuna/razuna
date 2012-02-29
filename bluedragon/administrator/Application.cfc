<!---
	Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org

	Contributing Developers:
	Matt Woodward - matt@mattwoodward.com

	This file is part of the Open BlueDragon Administrator.

	The Open BlueDragon Administrator is free software: you can redistribute 
	it and/or modify it under the terms of the GNU General Public License 
	as published by the Free Software Foundation, either version 3 of the 
	License, or (at your option) any later version.

	The Open BlueDragon Administrator is distributed in the hope that it will 
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
	General Public License for more details.

	You should have received a copy of the GNU General Public License 
	along with the Open BlueDragon Administrator.  If not, see 
	<http://www.gnu.org/licenses/>.
--->
<cfcomponent displayname"Application" output="false" hint="Application.cfc for OpenBD administrator">

	<cfscript>
		this.name = "OpenBDAdminConsole";
		this.sessionmanagement = true;
		this.setclientcookies = true;
		this.sessiontimeout = CreateTimeSpan(0,0,20,0);
	</cfscript>

	<cffunction name="onApplicationStart" access="public" output="false" returntype="boolean">
		<cfscript>
			Application.administrator = CreateObject("component", "bluedragon.adminapi.Administrator");
			Application.caching = CreateObject("component", "bluedragon.adminapi.Caching");
			Application.chart = CreateObject("component", "bluedragon.adminapi.Chart");
			Application.datasource = CreateObject("component", "bluedragon.adminapi.Datasource");
			Application.debugging = CreateObject("component", "bluedragon.adminapi.Debugging");
			Application.extensions = CreateObject("component", "bluedragon.adminapi.Extensions");
			Application.fonts = CreateObject("component", "bluedragon.adminapi.Fonts");
			Application.mail = CreateObject("component", "bluedragon.adminapi.Mail");
			Application.mapping = CreateObject("component", "bluedragon.adminapi.Mapping");
			Application.scheduledTasks = CreateObject("component", "bluedragon.adminapi.ScheduledTasks");
			Application.searchCollections = CreateObject("component", "bluedragon.adminapi.SearchCollections");
			Application.serverSettings = CreateObject("component", "bluedragon.adminapi.ServerSettings");
			Application.variableSettings = CreateObject("component", "bluedragon.adminapi.VariableSettings");
			Application.webServices = CreateObject("component", "bluedragon.adminapi.WebServices");

			Application.adminConsoleVersion = "2.0";
			Application.adminConsoleBuildDate = LSDateFormat(createDate(2011,11,11)) & " " & LSTimeFormat(createTime(00,00,00));

			// Need to make sure the basic security nodes exist in bluedragon.xml. Other potential missing nodes
			// are handled as the related pages within the administrator are hit.
			Application.administrator.setInitialSecurity();

			Application.inited = true;

			return true;
		</cfscript>
	</cffunction>

	<cffunction name="onRequestStart" access="public" output="false" returntype="boolean">
		<cfargument name="thePage" type="string" required="true" />

		<!--- handle the allow/deny IP addresses --->
		<cfset var allowedIPs = Application.administrator.getAllowedIPs() />
		<cfset var allowedIP = "" />
		<cfset var deniedIPs = Application.administrator.getDeniedIPs() />
		<cfset var deniedIP = "" />
		<cfset var allow = false />
		<cfset var remoteAddrOctets = "" />
		<cfset var allowedIPOctets = "" />
		<cfset var deniedIPOctets = "" />
		<cfset var octetMatchCount = 0 />
		<cfset var contextPath = "" />
		<cfset var i = 0 />

		<cfif !StructKeyExists(Application, "inited") or !Application.inited or StructKeyExists(url, "reload")>
			<cfset onApplicationStart() />
		</cfif>

		<!--- never deny localhost for safety's sake --->
		<cfif CGI.REMOTE_ADDR != "127.0.0.1" && (allowedIPs != "" or deniedIPs != "")>
			<!--- check denied IPs first--these take precedence over allows --->
			<cfif deniedIPs != "">
				<!--- if it's an exact match, obviously we abort --->
				<cfif ListFind(deniedIPs, CGI.REMOTE_ADDR, ",") != 0>
					<cfabort />
				<!--- if there are wildcards, need to check further --->
				<cfelseif ListContains(deniedIPs, "*", ",")>
					<cfloop list="#deniedIPs#" index="deniedIP">
						<cfset octetMatchCount = 0 />

						<cfif ListFind(deniedIP, "*", ".") != 0>
							<cfset remoteAddrOctets = ListToArray(CGI.REMOTE_ADDR, ".") />
							<cfset deniedIPOctets = ListToArray(deniedIP, ".") />

							<cfloop index="i" from="1" to="#ArrayLen(deniedIPOctets)#">
								<cfif remoteAddrOctets[i] == deniedIPOctets[i] || deniedIPOctets[i] == "*">
									<cfset octetMatchCount++ />
								</cfif>
							</cfloop>

							<cfif octetMatchCount == ArrayLen(deniedIPOctets)>
								<cfabort />
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			</cfif>

			<!--- check allow IPs --->
			<cfif allowedIPs != "">
				<cfif ListContains(allowedIPs, "*", ",")>
					<cfloop list="#allowedIPs#" index="allowedIP">
						<cfset octetMatchCount = 0 />

						<cfif ListFind(allowedIP, "*", ".") != 0>
							<cfset remoteAddrOctets = ListToArray(CGI.REMOTE_ADDR, ".") />
							<cfset allowedIPOctets = ListToArray(allowedIP, ".") />

							<cfloop index="i" from="1" to="#ArrayLen(allowedIPOctets)#">
								<cfif remoteAddrOctets[i] == allowedIPOctets[i] || allowedIPOctets[i] == "*">
									<cfset octetMatchCount++ />
								</cfif>
							</cfloop>

							<cfif octetMatchCount != ArrayLen(allowedIPOctets)>
								<cfabort />
							</cfif>
						</cfif>
					</cfloop>
				<cfelseif !ListFind(allowedIPs, CGI.REMOTE_ADDR, ",")>
					<cfabort />
				</cfif>
			</cfif>
		</cfif>

		<cfif !Application.administrator.isUserLoggedIn() && ListLast(CGI.SCRIPT_NAME, "/") != "login.cfm" &&
				ListLast(CGI.SCRIPT_NAME, "/") != "_loginController.cfm">
			<cfset contextPath = getPageContext().getRequest().getContextPath() />

			<cfif contextPath == "/">
				<cfset contextPath = "" />
			</cfif>

			<cflocation url="#contextPath#/bluedragon/administrator/login.cfm" addtoken="false" />
		</cfif>

		<cfreturn true />
	</cffunction>

	<cffunction name="onRequestEnd" access="public" output="true" returntype="void">
		<cfargument name="thePage" type="string" required="true" />

		<!--- clear out any lingering session data that's already been output --->
		<cfset StructDelete(session, "message", false) />
		<cfset StructDelete(session, "errorFields", false) />

		<cfif ListLast(CGI.SCRIPT_NAME, "/") == "login.cfm">
			<cfinclude template="/bluedragon/administrator/blankTemplate.cfm" />
		<cfelse>
			<cfinclude template="/bluedragon/administrator/template.cfm" />
		</cfif>
	</cffunction>

</cfcomponent>
