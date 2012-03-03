<cftry><cfsilent>
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

		<!--- FB5: allow "" default - FB41 required this variable: --->
		<cfparam name="variables.FUSEBOX_APPLICATION_PATH" default="" />
		<!--- FB5: application key - FB41 always uses 'fusebox': --->
		<cfparam name="variables.FUSEBOX_APPLICATION_KEY" default="fusebox" />
		<!--- FB51: allow application to be included from other directories: --->
		<cfparam name="variables.FUSEBOX_CALLER_PATH" default="#replace(getDirectoryFromPath(getBaseTemplatePath()),"\","/","all")#" />
		<!--- FB55: easy way to override fusebox.xml parameters programmatically: --->
		<cfparam name="variables.FUSEBOX_PARAMETERS" default="#structNew()#" />
		<!--- fake the application lifecycle for old-school non-Application.cfc applications --->
		<cfset __fuseboxAppCfc = createObject("component","Application").bleed(variables) />
		<cfloop item="__v" collection="#variables#">
			<cfset __fuseboxAppCfc.override(__v,variables[__v]) />
		</cfloop>
		<cfif isDefined("this")>
			<cfloop item="__v" collection="#this#">
				<!--- not safe to allow functions to be overridden --->
				<cfif not isCustomFunction(this[__v])>
					<cfset __fuseboxAppCfc.override(__v,this[__v],true) />
				</cfif>
			</cfloop>
		</cfif>
		<cfif not structKeyExists(application,FUSEBOX_APPLICATION_KEY)>
			<cflock name="#application.ApplicationName#_fusebox_#FUSEBOX_APPLICATION_KEY#" type="exclusive" timeout="300">
				<cfif not structKeyExists(application,FUSEBOX_APPLICATION_KEY)>
					<cfset __fuseboxAppCfc.onApplicationStart() />
				</cfif>
			</cflock>
		</cfif>
		<cfset __fuseboxAppCfc.onRequestStart(CGI.SCRIPT_NAME) />
	</cfsilent>
<cfcatch type="any">
	<cfif isDefined("__fuseboxAppCfc")>
		<cfset __fuseboxAppCfc.onError(cfcatch)>
	<cfelse>
		<cfrethrow />
	</cfif>
</cfcatch>
</cftry><cfprocessingdirective suppresswhitespace="true">
<cftry>
	<cfset __fuseboxAppCfc.onRequest(CGI.SCRIPT_NAME) />
	<cfset __fuseboxAppCfc.onRequestEnd(CGI.SCRIPT_NAME) />
<cfcatch type="any">
	<cfset __fuseboxAppCfc.onError(cfcatch)>
</cfcatch>
</cftry>
</cfprocessingdirective>
