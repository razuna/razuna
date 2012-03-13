<cfcomponent output="false">
	<cfprocessingdirective suppresswhitespace="true">
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

	<!--- code that must execute at the very start of every single request --->
	<!--- FB5: allow "" default - FB41 required this variable: --->
	<cfparam name="variables.FUSEBOX_APPLICATION_PATH" default="" />
	<!--- FB5: application key - FB41 always uses 'fusebox': --->
	<cfparam name="variables.FUSEBOX_APPLICATION_KEY" default="fusebox" />
	<!--- FB51: allow application to be included from other directories: --->
	<cfparam name="variables.FUSEBOX_CALLER_PATH" default="#replace(getDirectoryFromPath(getBaseTemplatePath()),"\","/","all")#" />
	<!--- FB55: easy way to override fusebox.xml parameters programmatically: --->
	<cfparam name="variables.FUSEBOX_PARAMETERS" default="#structNew()#" />
	
	<cfparam name="variables.attributes" default="#structNew()#" />
	<cfset structAppend(attributes,URL,true) />
	<cfset structAppend(attributes,form,true) />
	
	<!--- FB5: uses request.__fusebox for internal tracking of compiler / runtime operations: --->
	<cfset request.__fusebox = structNew() />
	
	<!--- FB55: bleeding variables scope back and forth between fusebox5.cfm and this CFC for backward compatibility --->
	<cfset variables.exposed = structNew() />
	
	<!--- FB55: scaffolder integration --->
	<cfif structKeyExists(attributes,"scaffolding.go")>
		<!--- if we're not already executing the scaffolder, branch to it --->
		<cfif findNoCase("/scaffolder/",CGI.SCRIPT_NAME) eq 0>
			<cftry>
				<cfinclude template="/scaffolder/manager.cfm" />
				<cfcatch type="missinginclude">
					<cfif structKeyExists(attributes,"scaffolding.debug")>
						<cfrethrow />
					</cfif>
					<cfthrow type="fusebox.noScaffolder" message="Scaffolder not found" detail="You requested the scaffolder but /scaffolder/index.cfm does not exist." />
				</cfcatch>
			</cftry>
		</cfif>
	</cfif>
	
	<cffunction name="bleed" returntype="any" access="public" output="false">
		<cfargument name="outerVariables" type="any" required="true" />
		
		<cfset variables.exposed = arguments.outerVariables />
		<!--- expose known variables: --->
		<cfset variables.exposed.attributes = variables.attributes />
		
		<cfreturn this />
		
	</cffunction>

	<cffunction name="onApplicationStart" output="false">

		<!--- FB5: myFusebox is an object but has FB41-compatible public properties --->
		<cfset variables.myFusebox = createObject("component","myFusebox").init(variables.FUSEBOX_APPLICATION_KEY,variables.attributes,variables) />
		<!--- expose known variables: --->
		<cfset variables.exposed.myFusebox = variables.myFusebox />

		<!--- FB55: guarantee XFA struct exists --->
		<cfparam name="variables.xfa" default="#structNew()#" />
		<!--- FB51: ticket 164: add OO synonym for attributes scope --->
		<cfparam name="variables.event" default="#createObject('component','fuseboxEvent').init(attributes,xfa,myFusebox)#" />
		<!--- expose known variables: --->
		<cfset variables.exposed.xfa = variables.xfa />
		<cfset variables.exposed.event = variables.event />
		
		<cfset loadFusebox() />

	</cffunction>
	
	<cffunction name="onSessionStart" output="false">
	</cffunction>
	
	<cffunction name="onRequestStart" output="false">
		<cfargument name="targetPage" type="string" required="true" />
		
		<cfset var doCompile = true />
		
		<!--- ensure CFC / Web Service / Flex Remoting calls are not intercepted --->
		<cfif right(arguments.targetPage,4) is ".cfc">
			<cfset doCompile = false />
			<cfset structDelete(variables,"onRequest") />
			<cfset structDelete(this,"onRequest") />
		</cfif>
		
		<!--- onApplicationStart() may create this (on first request) --->
		<cfif not structKeyExists(variables,"myFusebox")>
			<!--- FB5: myFusebox is an object but has FB41-compatible public properties --->
			<cfset variables.myFusebox = createObject("component","myFusebox").init(variables.FUSEBOX_APPLICATION_KEY,variables.attributes,variables) />
			<!--- expose known variables: --->
			<cfset variables.exposed.myFusebox = variables.myFusebox />
		</cfif>

		<!--- FB55: guarantee XFA struct exists --->
		<cfparam name="variables.xfa" default="#structNew()#" />
		<!--- FB51: ticket 164: add OO synonym for attributes scope --->
		<cfparam name="variables.event" default="#createObject('component','fuseboxEvent').init(variables.attributes,variables.xfa,variables.myFusebox)#" />
		<!--- expose known variables: --->
		<cfset variables.exposed.xfa = variables.xfa />
		<cfset variables.exposed.event = variables.event />
		
		<cfif variables.myFusebox.parameters.load>
			<cflock name="#application.ApplicationName#_fusebox_#variables.FUSEBOX_APPLICATION_KEY#" type="exclusive" timeout="300">
				<cfif variables.myFusebox.parameters.load>
					<cfset loadFusebox() />
				<cfelse>
					<!--- _fba should *not* be exposed --->
					<cfset _fba = application[variables.FUSEBOX_APPLICATION_KEY] />
					<!--- fix attributes precedence --->
					<cfif _fba.precedenceFormOrURL is "URL">
						<cfset structAppend(variables.attributes,URL,true) />
					</cfif>
					<!--- set the default fuseaction if necessary --->
					<cfif not structKeyExists(variables.attributes,_fba.fuseactionVariable) or trim(variables.attributes[_fba.fuseactionVariable]) is "">
						<cfset variables.attributes[_fba.fuseactionVariable] = _fba.defaultFuseaction />
					</cfif>
					<cfset variables.attributes[_fba.fuseactionVariable] = trim(variables.attributes[_fba.fuseactionVariable]) />
					<cfset variables.attributes.fuseaction = variables.attributes[_fba.fuseactionVariable] />
				</cfif>
			</cflock>
		<cfelse>
			<cfset _fba = application[variables.FUSEBOX_APPLICATION_KEY] />
			<!--- fix attributes precedence --->
			<cfif _fba.precedenceFormOrURL is "URL">
				<cfset structAppend(variables.attributes,URL,true) />
			</cfif>
			<!--- set the default fuseaction if necessary --->
			<cfif not structKeyExists(variables.attributes,_fba.fuseactionVariable) or trim(variables.attributes[_fba.fuseactionVariable]) is "">
				<cfset variables.attributes[_fba.fuseactionVariable] = _fba.defaultFuseaction />
			</cfif>
			<cfset variables.attributes[_fba.fuseactionVariable] = trim(variables.attributes[_fba.fuseactionVariable]) />
			<cfset variables.attributes.fuseaction = variables.attributes[_fba.fuseactionVariable] />
		</cfif>

		<!---
			Fusebox 4.1 did not set attributes.fuseaction or default the fuseaction variable until
			*after* fusebox.init.cfm had run. This made it hard for fusebox.init.cfm to do URL
			rewriting. For Fusebox 5, we default the fuseaction variable and set attributes.fuseaction
			before fusebox.init.cfm so it can rely on attributes.fuseaction and rewrite that. However,
			in order to maintain backward compatibility, we need to allow fusebox.init.cfm to set
			attributes[_fba.fuseactionVariable] and still have that reflected in attributes.fuseaction
			and for that to actually be the request that gets processed.
		--->
		<cfif _fba.debug>
			<cfset variables.myFusebox.trace("Fusebox","Including fusebox.init.cfm") />
		</cfif>
		<cftry>
			<!--- _fba_ttr_fav and _ba_attr_fa should *not* be exposed --->
			<cfset _fba_attr_fav = variables.attributes[_fba.fuseactionVariable] />
			<cfset _fba_attr_fa = variables.attributes.fuseaction />
			<cfinclude template="#_fba.getCoreToAppRootPath()#fusebox.init.cfm" />
			<cfif variables.attributes.fuseaction is not _fba_attr_fa>
				<cfif variables.attributes.fuseaction is not variables.attributes[_fba.fuseactionVariable]>
					<cfif variables.attributes[_fba.fuseactionVariable] is not _fba_attr_fav>
						<!--- inconsistent modification of both variables?!? --->
						<cfthrow type="fusebox.inconsistentFuseaction"
								message="Inconsistent fuseaction variables"
								detail="Both attributes.fuseaction and attributes[{fusebox}.fuseactionVariable] changed in fusebox.init.cfm so Fusebox doesn't know what to do with the values!" />
					<cfelse>
						<!--- ok, only attributes.fuseaction changed --->
						<cfset variables.attributes[_fba.fuseactionVariable] = variables.attributes.fuseaction />
					</cfif>
				<cfelse>
					<!--- ok, they were both changed and they match --->
				</cfif>
			<cfelse>
				<!--- attributes.fuseaction did not change --->
				<cfif variables.attributes[_fba.fuseactionVariable] is not _fba_attr_fav>
					<!--- make attributes.fuseaction match the other changed variable --->
					<cfset variables.attributes.fuseaction = variables.attributes[_fba.fuseactionVariable] />
				<cfelse>
					<!--- ok, neither variable changed --->
				</cfif>
			</cfif>
		<cfcatch type="missinginclude" />
		</cftry>
		<cfif doCompile>
			<!---
				must special case development-circuit-load mode since it causes circuits to reload during
				the compile (post-load) phase and therefore must be exclusive
			--->
			<cfif _fba.debug>
				<cfset variables.myFusebox.trace("Fusebox","Compiling requested fuseaction '#variables.attributes.fuseaction#'") />
			</cfif>
			<!--- _parsedFileData should *not* be exposed --->
			<cfif _fba.mode is "development-circuit-load">
				<cflock name="#application.ApplicationName#_fusebox_#variables.FUSEBOX_APPLICATION_KEY#" type="exclusive" timeout="300">
					<cfset _parsedFileData = _fba.compileRequest(attributes.fuseaction,myFusebox) />
				</cflock>
			<cfelse>
				<cflock name="#application.ApplicationName#_fusebox_#variables.FUSEBOX_APPLICATION_KEY#" type="readonly" timeout="300">
					<cfset _parsedFileData = _fba.compileRequest(attributes.fuseaction,myFusebox) />
				</cflock>
			</cfif>
		</cfif>
		
	</cffunction>
	
	<!--- excuse the formatting here - it is done to completely suppress whitespace --->
	<cffunction name="onRequest"><cfargument 
				name="targetPage" type="string" required="true" /><cfsetting 
							enablecfoutputonly="true">
		
		<cfif variables.myFusebox.parameters.execute>
			<cfif _fba.debug>
				<cfset myFusebox.trace("Fusebox","Including parsed file for '#variables.attributes.fuseaction#'") />
			</cfif>
			<cftry>
				<!---
					readonly lock protects against including the parsed file while
					another threading is writing it...
				--->
				<cflock name="#_parsedFileData.lockName#" type="readonly" timeout="30">
					<cfinclude template="#_parsedFileData.parsedFile#" />
				</cflock>
			<cfcatch type="missinginclude">
				<cfif right(cfcatch.missingFileName, len(_parsedFileData.parsedName)) is _parsedFileData.parsedName>
					<cfthrow type="fusebox.missingParsedFile" 
							message="Parsed File or Directory not found."
							detail="Attempting to execute the parsed file '#_parsedFileData.parsedName#' threw an error. This can occur if the parsed file does not exist in the parsed directory or if the parsed directory itself is missing." />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
			</cftry>
		</cfif>
		
		<cfsetting enablecfoutputonly="false">
	</cffunction>
	
	<cffunction name="onRequestEnd" output="true">
		<cfargument name="targetPage" type="string" required="true" />

		<cfif structKeyExists(variables,"myFusebox")>
			<cfset variables.myFusebox.trace("Fusebox","Request completed") />
		</cfif>
		<cfif isDefined("_fba.debug") and _fba.debug and structKeyExists(variables,"myFusebox") and right(arguments.targetPage,4) is not ".cfc">
			<cfoutput>#variables.myFusebox.renderTrace()#</cfoutput>
		</cfif>

	</cffunction>
	
	<cffunction name="onSessionEnd" output="false">
	</cffunction>
	
	<cffunction name="onApplicationEnd" output="false">
	</cffunction>
	
	<cffunction name="onError">
		<cfargument name="exception" />
		
		<cfset var stack = 0 />
		<cfset var prefix = "Raised at " />
		
		<!--- top-level exception is always event name / expression for Application.cfc (but not fusebox5.cfm) --->
		<cfset var caughtException = arguments.exception />
		
		<cfif structKeyExists(caughtException,"rootcause")>
			<cfset caughtException = caughtException.rootcause />
		</cfif>
		
		<cfif listFirst(caughtException.type,".") is "fusebox">
			<cfif isDefined("_fba.debug") and _fba.debug and structKeyExists(variables,"myFusebox")>
				<cfset variables.myFusebox.trace("Fusebox","Caught Fusebox exception '#caughtException.type#'") />
				<cfif structKeyExists(caughtException,"tagcontext")>
					<cfloop index="stack" from="1" to="#arrayLen(caughtException.tagContext)#">
						<cfset variables.myFusebox.trace("Fusebox",prefix & 
								caughtException.tagContext[stack].template & ":" & 
								caughtException.tagContext[stack].line) />
						<cfset prefix = "Called from " />
					</cfloop>
				</cfif>
			</cfif>
			<cfif not isDefined("_fba.errortemplatesPath") or (
					structKeyExists(variables,"attributes") and structKeyExists(variables,"myFusebox") and
					not _fba.handleFuseboxException(caughtException,variables.attributes,variables.myFusebox,variables.FUSEBOX_APPLICATION_KEY)
					)>
				<cfif isDefined("_fba.debug") and _fba.debug and structKeyExists(variables,"myFusebox")>
					<cfoutput>#variables.myFusebox.renderTrace()#</cfoutput>
				</cfif>
				<cfthrow object="#caughtException#" />
			</cfif>
		<cfelse>
			<cfif isDefined("_fba.debug") and _fba.debug and structKeyExists(variables,"myFusebox")>
				<cfset variables.myFusebox.trace("Fusebox","Request failed with exception '#caughtException.type#' (#caughtException.message#)") />
				<cfif structKeyExists(caughtException,"tagcontext")>
					<cfloop index="stack" from="1" to="#arrayLen(caughtException.tagContext)#">
						<cfset variables.myFusebox.trace("Fusebox",prefix & 
								caughtException.tagContext[stack].template & ":" & 
								caughtException.tagContext[stack].line) />
						<cfset prefix = "Called from " />
					</cfloop>
				</cfif>
				<cfoutput>#variables.myFusebox.renderTrace()#</cfoutput>
			</cfif>
			<cfthrow object="#caughtException#" />
		</cfif>
		
		<!--- if we hit an error before starting the request, prevent the request from running --->
		<cfset myFusebox.parameters.execute = false />
		
	</cffunction>
	
	<cffunction name="override" returntype="void" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="value" type="any" required="true" />
		<cfargument name="useThisScope" type="boolean" default="false" />
		
		<cfif arguments.useThisScope>
			<cfset this[arguments.name] = arguments.value />
		<cfelse>
			<cfset variables[arguments.name] = arguments.value />
		</cfif>
		
	</cffunction>
	
	<cffunction name="onFuseboxApplicationStart">
	</cffunction>
	
	<cffunction name="loadFusebox" access="private" output="false">
		<!--- ticket 232: extend request timeout value on framework load --->
		<cfsetting requesttimeout="600" />
		<cfif not structKeyExists(application,variables.FUSEBOX_APPLICATION_KEY) or variables.myFusebox.parameters.userProvidedLoadParameter>
			<!--- can't be conditional: we don't know the state of the debug flag yet --->
			<cfset variables.myFusebox.trace("Fusebox","Creating Fusebox application object") />
			<cfset _fba = createObject("component","fuseboxApplication") />
			<cfset application[variables.FUSEBOX_APPLICATION_KEY] = _fba.init(variables.FUSEBOX_APPLICATION_KEY,variables.FUSEBOX_APPLICATION_PATH,variables.myFusebox,variables.FUSEBOX_CALLER_PATH,variables.FUSEBOX_PARAMETERS) />
		<cfelse>
			<!--- can't be conditional: we don't know the state of the debug flag yet --->
			<cfset variables.myFusebox.trace("Fusebox","Reloading Fusebox application object") />
			<cfset _fba = application[variables.FUSEBOX_APPLICATION_KEY] />
			<!--- it exists and the load is implicit, not explicit (via user) so just reload XML --->
			<cfset _fba.reload(variables.FUSEBOX_APPLICATION_KEY,variables.FUSEBOX_APPLICATION_PATH,variables.myFusebox,variables.FUSEBOX_PARAMETERS) />
		</cfif>
		<!--- fix attributes precedence --->
		<cfif _fba.precedenceFormOrURL is "URL">
			<cfset structAppend(variables.attributes,URL,true) />
		</cfif>
		<!--- set the default fuseaction if necessary --->
		<cfif not structKeyExists(variables.attributes,_fba.fuseactionVariable) or variables.attributes[_fba.fuseactionVariable] is "">
			<cfset variables.attributes[_fba.fuseactionVariable] = _fba.defaultFuseaction />
		</cfif>
		<!--- set this up for fusebox.appinit.cfm --->
		<cfset variables.attributes.fuseaction = variables.attributes[_fba.fuseactionVariable] />
		<!--- flag this as the first request for the application --->
		<cfset variables.myFusebox.applicationStart = true />
		<!--- force parse after reload for consistency in development modes --->
		<cfif _fba.mode is not "production" or variables.myFusebox.parameters.userProvidedLoadParameter>
			<cfset variables.myFusebox.parameters.parse = true />
		</cfif>
		<!--- need all of the above set before we attempt any compiles! --->
		<cfif variables.myFusebox.parameters.parseall>
			<cfset _fba.compileAll(variables.myFusebox) />
		</cfif>
		<!--- FB55: template method to allow no-XML application initialization --->
		<cfif _fba.debug>
			<cfset variables.myFusebox.trace("Fusebox","Executing onFuseboxApplicationStart()") />
		</cfif>
		<cfset onFuseboxApplicationStart() />
		<!--- FB5: new appinit include file --->
		<cfif _fba.debug>
			<cfset variables.myFusebox.trace("Fusebox","Including fusebox.appinit.cfm") />
		</cfif>
		<cftry>
			<cfinclude template="#_fba.getCoreToAppRootPath()#fusebox.appinit.cfm" />
		<cfcatch type="missinginclude" />
		</cftry>
		<!--- ticket 269 ensure there is no double reload at CF startup --->
		<cfset variables.myFusebox.parameters.load = false />
	</cffunction>
	
	</cfprocessingdirective>
</cfcomponent>