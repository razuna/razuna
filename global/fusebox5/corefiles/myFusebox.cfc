<!---
Copyright 2006-2007 TeraTech, Inc. http://teratech.com/

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->
<cfcomponent hint="I provide the per-request myFusebox data structure and some convenience methods.">
	<cfscript>
	this.version.runtime     = "5.5.1";
	//this.version.runtime     = "5.5.0.#REReplace('$LastChangedRevision:683 $','[^0-9]','','all')#";
	  
	this.version.loader      = "unknown";
	this.version.transformer = "unknown";
	this.version.parser      = "unknown";
	  
	this.thisCircuit = "";
	this.thisFuseaction =  "";
	this.thisPlugin = "";
	this.thisPhase = "";
	this.plugins = structNew();
	this.parameters = structNew();
	
	// the basic default is development-full-load mode:
	this.parameters.load = true;
	this.parameters.parse = true;
	this.parameters.execute = true;
	// FB5: new execution parameters:
	this.parameters.clean = false;	 	// don't delete parsed files by default
	this.parameters.parseall = false;	// don't compile all fuseactions by default
	  
	this.parameters.userProvidedLoadParameter = false;
	this.parameters.userProvidedCleanParameter = false;
	this.parameters.userProvidedParseParameter = false;
	this.parameters.userProvidedParseAllParameter = false;
	this.parameters.userProvidedExecuteParameter = false;
	
	// stack frame for do/include parameters:
	this.stack = structNew();
	
	// FB55: ability to turn debug output off per-request:
	this.showDebug = true;
	</cfscript>
	
	<cffunction name="init" returntype="myFusebox" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="appKey" type="string" required="true" 
					hint="I am FUSEBOX_APPLICATION_KEY." />
		<cfargument name="attributes" type="struct" required="true" 
					hint="I am the attributes (URL and form variables) structure." />
		<cfargument name="topLevelVariablesScope" type="any" required="true" 
					hint="I am the top-level variables scope." />
		
		<cfset var theFusebox = structNew() />
		<cfset var urlParam = "" />
		<cfset var urlLastArg = "" />
		<cfset var urlIsArg = true />
		<cfset var pathInfo = CGI.PATH_INFO />
		
		<cfset variables.variablesScope = arguments.topLevelVariablesScope />
		
		<cfset variables.created = getTickCount() />
		<cfset variables.log = arrayNew(1) />
		<cfset variables.occurrence = structNew() />

		<cfset variables.appKey = arguments.appKey />
		<cfset variables.attributes = arguments.attributes />
		
		<!--- FB5: indicates whether application was started on this request --->
		<cfset this.applicationStart = false />

		<!--- we can't guarantee the fusebox exists in application scope yet... --->
		<cfif structKeyExists(application,variables.appKey)>
			<cfset theFusebox = application[variables.appKey] />
		</cfif>
		
		<!--- default myFusebox.parameters depending on "mode" of the application set in fusebox.xml --->
		<cfif structKeyExists(theFusebox,"mode")>
			<cfswitch expression="#theFusebox.mode#">
			<!--- FB41 backward compatibility - now deprecated --->
			<cfcase value="development">
				<cfif structKeyExists(theFusebox,"strictMode") and theFusebox.strictMode>
					<!--- since we don't load fusebox.xml if we throw an exception, we must fixup the value for the next run --->
					<cfset theFusebox.mode = "development-full-load" />
					<cfthrow type="fusebox.badGrammar.deprecated" 
							message="Deprecated feature"
							detail="'development' is a deprecated execution mode - use 'development-full-load' instead." />
				</cfif>
				<cfset this.parameters.load = true />
				<cfset this.parameters.parse = true />
				<cfset this.parameters.execute = true />
			</cfcase>
			<!--- FB5: replacement for old development mode --->
			<cfcase value="development-full-load">
				<cfset this.parameters.load = true />
				<cfset this.parameters.parse = true />
				<cfset this.parameters.execute = true />
			</cfcase>
			<!--- FB5: new option - does not load fusebox.xml and therefore does not (re-)load fuseboxApplication object --->
			<cfcase value="development-circuit-load">
				<cfset this.parameters.load = false />
				<cfset this.parameters.parse = true />
				<cfset this.parameters.execute = true />
			</cfcase>
			<cfcase value="production">
				<cfset this.parameters.load = false />
				<cfset this.parameters.parse = false />
				<cfset this.parameters.execute = true />
			</cfcase>
			<cfdefaultcase>
				<!--- since we don't load fusebox.xml if we throw an exception, we must fixup the value for the next run --->
				<cfset theFusebox.mode = "development-full-load" />
				<cfthrow type="fusebox.badGrammar.invalidParameterValue" 
						message="Parameter has invalid value" 
						detail="The parameter 'mode' must be one of 'development-full-load', 'development-circuit-load' or 'production' in the fusebox.xml file." />
			</cfdefaultcase>
			</cfswitch>
		</cfif>
		
		<!--- handle SES URLs if appropriate --->
		<cfif structKeyExists(theFusebox,"queryStringStart") and theFusebox.queryStringStart is not "?">
			<!--- looks like SES URL generation is enabled, process CGI.PATH_INFO (we add &= to catch improperly formed URLs) --->
			<!--- ticket 313 - canonicalize pathInfo for IIS 5 --->
			<cfif len(pathInfo) gt len(CGI.SCRIPT_NAME) and left(pathInfo,len(CGI.SCRIPT_NAME)) is CGI.SCRIPT_NAME>
				<cfset pathInfo = right(pathInfo,len(pathInfo)-len(CGI.SCRIPT_NAME)) />
			</cfif>
			<cfloop list="#pathInfo#" index="urlParam" 
					delimiters="#theFusebox.queryStringStart##theFusebox.queryStringSeparator##theFusebox.queryStringEqual#&=">
			   <cfif urlIsArg>
			      <cfset urlLastArg = urlParam />
			   <cfelse>
			      <cfset variables.attributes[urlLastArg] = urlParam />
			   </cfif>
			   <cfset urlIsArg = not urlIsArg />
			</cfloop>
		</cfif>
		
		<!--- did the user pass in any special "fuseboxDOT" parameters for this request? --->
		<!--- If so, process them --->
		<!--- note: only if attributes.fusebox.password matches the application password --->
		<cfif not structKeyExists(variables.attributes,"fusebox.password")>
			<cfset variables.attributes["fusebox.password"] = "" />
		</cfif>
		<cfif structKeyExists(theFusebox,"password") and
				theFusebox.password is variables.attributes['fusebox.password']>
			<!--- FB5: does a load and wipes the parsed files out --->
			<cfif structKeyExists(variables.attributes,'fusebox.loadclean') and isBoolean(variables.attributes['fusebox.loadclean'])>
				<cfset this.parameters.load = variables.attributes['fusebox.loadclean'] />
				<cfset this.parameters.clean = variables.attributes['fusebox.loadclean'] />
				<cfset this.parameters.userProvidedLoadParameter = true />
				<cfset this.parameters.userProvidedCleanParameter = true />
			</cfif>
			<cfif structKeyExists(variables.attributes,'fusebox.load') and isBoolean(variables.attributes['fusebox.load'])>
				<cfset this.parameters.load = variables.attributes['fusebox.load'] />
				<cfset this.parameters.userProvidedLoadParameter = true />
			</cfif>
			<cfif structKeyExists(variables.attributes,'fusebox.parseall') and isBoolean(variables.attributes['fusebox.parseall'])>
				<cfset this.parameters.parse = variables.attributes['fusebox.parseall'] />
				<cfset this.parameters.parseall = variables.attributes['fusebox.parseall'] />
				<cfif this.parameters.parseall>
					<cfset this.parameters.load = true />
				</cfif>
				<cfset this.parameters.userProvidedParseParameter = true />
				<cfset this.parameters.userProvidedParseAllParameter = true />
			</cfif>
			<cfif structKeyExists(variables.attributes,'fusebox.parse') and isBoolean(variables.attributes['fusebox.parse'])>
				<cfset this.parameters.parse = variables.attributes['fusebox.parse'] />
				<cfset this.parameters.userProvidedParseParameter = true />
			</cfif>
			<cfif structKeyExists(variables.attributes,'fusebox.execute') and isBoolean(variables.attributes['fusebox.execute'])>
				<cfset this.parameters.execute = variables.attributes['fusebox.execute'] />
				<cfset this.parameters.userProvidedExecuteParameter = true />
			</cfif>
		</cfif>
		
		<!---
			force a load if the runtime and core versions differ: this allows a new
			version to be dropped in and the framework will automatically reload!
			note: that we must *force* a load, by pretending this is user-provided!
		--->
		<cfif structKeyExists(theFusebox,"getVersion") and
				isCustomFunction(theFusebox.getVersion)>
			<cfif this.version.runtime is not theFusebox.getVersion()>
				<cfset this.parameters.userProvidedLoadParameter = true />
				<cfset this.parameters.load = true />
			</cfif>
		<cfelse>
			<!--- hmm, doesn't look like the core is present (or it's not FB5 Alpha 2 or higher) --->
			<cfset this.parameters.userProvidedLoadParameter = true />
			<cfset this.parameters.load = true />
		</cfif>

		<!--- if the fusebox doesn't already exist we definitely want to reload --->
		<cfif structKeyExists(theFusebox,"isFullyLoaded") and
				theFusebox.isFullyLoaded>
			<!--- if fully loaded, leave the load parameter alone --->
		<cfelse>
			<cfset this.parameters.load = true />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getApplication" returntype="any" access="public" output="false" 
				hint="I am a convenience method to return the fuseboxApplication object without needing to know reference application scope or the FUSEBOX_APPLICATION_KEY variable.">
	
		<!---
			this is a bit of a hack since we're accessing application scope directly 
			but it's probably cleaner than exposing a method to allow fuseboxApplication
			to inject itself back into myFusebox during compileRequest()...
		--->
		<cfreturn application[variables.appKey] />
	
	</cffunction>
	
	<cffunction name="getApplicationData" returntype="struct" access="public" output="false"
				hint="I am a convenience method to return a reference to the application data cache.">
	
		<cfreturn getApplication().getApplicationData() />
	
	</cffunction>
	
	<cffunction name="getCurrentCircuit" returntype="any" access="public" output="false" 
				hint="I am a convenience method to return the current Fusebox circuit object.">
	
		<cfreturn getApplication().circuits[this.thisCircuit] />
	
	</cffunction>
	
	<cffunction name="getCurrentFuseaction" returntype="any" access="public" output="false" 
				hint="I am a convenience method to return the current fuseboxAction (fuseaction) object.">
	
		<cfreturn getCurrentCircuit().fuseactions[this.thisFuseaction] />
	
	</cffunction>
	
	<cffunction name="getOriginalCircuit" returntype="any" access="public" output="false" 
				hint="I am a convenience method to return the original Fusebox circuit object.">
	
		<cfreturn getApplication().circuits[this.originalCircuit] />
	
	</cffunction>
	
	<cffunction name="getOriginalFuseaction" returntype="any" access="public" output="false" 
				hint="I am a convenience method to return the original fuseboxAction (fuseaction) object.">
	
		<cfreturn getCurrentCircuit().fuseactions[this.originalFuseaction] />
	
	</cffunction>
	
	<cffunction name="getSelf" returntype="string" access="public" output="false"
				hint="I return the 'self' string, e.g., index.cfm.">

		<cfif not structKeyExists(variables,"self")>
			<cfset variables.self = getApplication().self />
		</cfif>
		
		<cfreturn variables.self />

	</cffunction>	
	
	<cffunction name="setSelf" returntype="void" access="public" output="false" 
				hint="I override the default value of 'self' and I also reset the value of 'myself'.">
		<cfargument name="self" type="string" required="true" 
					hint="I am the new value of 'self', e.g., /myapp/entry.cfm" />
		
		<cfset variables.self = arguments.self />
		<!--- reset myself for consistency with self --->
		<cfset variables.myself = getApplication().getDefaultMyself(variables.self) />
		
	</cffunction>

	<cffunction name="getMyself" returntype="string" access="public" output="false" 
				hint="I return the 'myself' string, e.g., index.cfm?fuseaction=.">

		<cfif not structKeyExists(variables,"myself")>
			<cfset variables.myself = getApplication().myself />
		</cfif>
		
		<cfreturn variables.myself />

	</cffunction>	
	
	<cffunction name="setMyself" returntype="void" access="public" output="false" 
				hint="I override the default value of 'myself'.">
		<cfargument name="myself" type="string" required="true" 
					hint="I am the new value of 'myself'." />
		
		<cfset variables.myself = arguments.myself />
		
	</cffunction>

	<cffunction name="do" returntype="string" access="public" output="true" 
				hint="I compile and execute a specific fuseaction.">
		<cfargument name="action" type="string" required="true" 
					hint="I am the full name of the requested fuseaction (circuit.fuseaction)." />
		<cfargument name="contentVariable" type="string" default="" 
					hint="I indicate an attributes / event scope variable in which to store the output." />
		<cfargument name="returnOutput" type="boolean" default="false" 
					hint="I indicate whether to display output (false - default) or return the output (true)." />
		<cfargument name="append" type="boolean" default="false" 
					hint="I indicate whether to append output (false - default) to the content variable." />

		<cfset var c = this.thisCircuit />
		<cfset var f = this.thisFuseaction />
		<cfset var output = 
				getApplication().do(
					arguments.action,
					this,
					arguments.returnOutput or arguments.contentVariable is not "") />
	
		<cfset this.thisFuseaction = f />
		<cfset this.thisCircuit = c />
			
		<cfif arguments.contentVariable is not "">
			<!--- ticket #290 - allow append on content variables --->
			<cfif structKeyExists(variables.variablesScope,arguments.contentVariable) and arguments.append>
				<cfset variables.variablesScope[arguments.contentVariable] = variables.variablesScope[arguments.contentVariable] & output />
			<cfelse>
				<cfset variables.variablesScope[arguments.contentVariable] = output />
			</cfif>
		</cfif>
		
		<cfreturn output />
		
	</cffunction>
	
	<cffunction name="relocate" returntype="void" access="public" output="true" 
				hint="I provide the same functionality as the relocate verb.">
		<cfargument name="url" type="string" required="false" />
		<cfargument name="xfa" type="string" required="false" />
		<cfargument name="addtoken" type="boolean" default="false" />
		<cfargument name="type" type="string" default="client" />

		<cfset var theUrl = "" />
		
		<!--- url/xfa - exactly one is required --->
		<cfif structKeyExists(arguments,"url")>
			<cfif structKeyExists(arguments,"xfa")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing" 
						message="Required attribute is missing" 
						detail="Either the attribute 'url' or 'xfa' is required, for a 'relocate' verb in fuseaction #this.thiscircuit#.#this.thisFuseaction#." />
			<cfelse>
				<cfset theUrl = arguments.url />
			</cfif>
		<cfelseif structKeyExists(arguments,"xfa")>
			<cfset theUrl = getMyself() & variables.variablesScope.xfa[arguments.xfa] />
		<cfelse>
			<cfthrow type="fusebox.badGrammar.requiredAttributeMissing" 
					message="Required attribute is missing" 
					detail="Either the attribute 'url' or 'xfa' is required, for a 'relocate' verb in fuseaction #this.thiscircuit#.#this.thisFuseaction#." />
		</cfif>
		
		<!--- type - server|client|moved - we do not support javascript here --->
		<cfif arguments.type is "server">

			<cfset getPageContext().forward(theUrl) />

		<cfelseif arguments.type is "client">

			<cflocation url="#theUrl#" addtoken="#arguments.addtoken#" />

		<cfelseif arguments.type is "moved">

			<cfheader statuscode="301" statustext="Moved Permanently" />
			<cfheader name="Location" value="#theUrl#" />
			
		<cfelse>
			<cfthrow type="fusebox.badGrammar.invalidAttributeValue" 
					message="Attribute has invalid value" 
					detail="The attribute 'type' must either be ""server"", ""client"" or ""moved"", for a 'relocate' verb in fuseaction #this.thisCircuit#.#this.thisFuseaction#." />
		</cfif>
		
		<cfabort />

	</cffunction>
	
	<cffunction name="variables" returntype="any" access="public" output="false" hint="I return the top-level variables scope.">
	
		<cfreturn variables.variablesScope />
	
	</cffunction>
	
	<cffunction name="enterStackFrame" returntype="void" access="public" output="false" 
				hint="I create a new stack frame (for scoped parameters to do/include).">
		
		<cfset var frame = structNew() />
		
		<cfset frame.__fuseboxStack = this.stack />
		<cfset this.stack = frame />
		
	</cffunction>
	
	<cffunction name="leaveStackFrame" returntype="void" access="public" output="false" 
				hint="I pop the last stack frame (for scoped parameters to do/include).">
		
		<cfset this.stack = this.stack.__fuseboxStack />
		
	</cffunction>
	
	<cffunction name="trace" returntype="void" access="public" output="false" 
				hint="I add a line to the execution trace log.">
		<cfargument name="type" hint="I am the type of trace (Fusebox, Compiler, Runtime are used by the framework)." />
		<cfargument name="message" hint="I am the message to put in the execution trace." />
		
		<cfset addTrace(getTickCount() - variables.created,arguments.type,arguments.message) />
		
	</cffunction>

	<cffunction name="addTrace" returntype="void" access="private" output="false" 
				hint="I add a detailed line to the execution trace log.">
		<cfargument name="time" hint="I am the time taken to get to this point in the request." />
		<cfargument name="type" hint="I am the type of trace." />
		<cfargument name="message" hint="I am the trace message." />
		<cfargument name="occurrence" default="0" hint="I am a placeholder for part of the struct that is added to the log." />
		
		<cfif structKeyExists(variables.occurrence,arguments.message)>
			<cfset variables.occurrence[arguments.message] = 1 + variables.occurrence[arguments.message] />
		<cfelse>
			<cfset variables.occurrence[arguments.message] = 1 />
		</cfif>
		<cfset arguments.occurrence = variables.occurrence[arguments.message] />
		<cfset arrayAppend(variables.log,arguments) />
		
	</cffunction>
	
	<cffunction name="renderTrace" returntype="string" access="public" output="false" hint="I render the trace log as HTML.">
		
		<cfset var result = "" />
		<cfset var i = 0 />
		
		<cfif this.showDebug>
			<cfsavecontent variable="result">
				<style type="text/css">
					.fuseboxdebug {clear:both;padding-top:10px;}
					.fuseboxdebug * {font-family:verdana,sans-serif;}
					.fuseboxdebug h3 {margin:16px 0 16px 0;padding:0;border-bottom:1px solid #CCC;font-size:16px;}
					.fuseboxdebug table th {font-size:11pt;text-align:left;}
					.fuseboxdebug table tr.odd {background:#F9F9F9;}
					.fuseboxdebug table tr.even {background:#FFF;}
					.fuseboxdebug table td {border-bottom:1px solid #CCC;font-size:10pt;text-align:left;vertical-align:top;}
					.fuseboxdebug table td.count {text-align:center;}
				</style>
				<div class="fuseboxdebug">
					<h3>Fusebox debugging:</h3>
					<table cellpadding="2" cellspacing="0" width="100%">
						<tr>
							<th>Time</td>
							<th>Category</td>
							<th>Message</td>
							<th>Count</td>
						</tr>
						<cfloop index="i" from="1" to="#arrayLen(variables.log)#">
							<cfoutput>
								<cfif i mod 2>
									<tr class="odd">
								<cfelse>
									<tr class="even">
								</cfif>
								<td>#variables.log[i].time#ms</td>
								<td>#variables.log[i].type#</td>
								<td>#variables.log[i].message#</td>
								<td class="count">#variables.log[i].occurrence#</td>
							</tr></cfoutput>
						</cfloop>
					</table>
				</div>
			</cfsavecontent>
		</cfif>
		
		<cfreturn result />
		
	</cffunction>
</cfcomponent>
