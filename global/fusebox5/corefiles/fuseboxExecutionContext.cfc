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
<cfcomponent output="false">

	<cffunction name="__executeDynamicDo" returntype="string" access="public" output="true" 
				hint="I execute a dynamically generated do fuseaction.">
		<cfargument name="parsedFileInfo" type="struct" required="true" 
					hint="I am the information about the parsed file." />
		<cfargument name="myFusebox" type="myFusebox" required="true" 
					hint="I am the myFusebox data structure." />
		<cfargument name="returnOutput" type="boolean" required="true"
					hint="I indicate whether to display output (false) or return the output (true)." />

		<cfset var output = "" />
		
		<cfif structKeyExists(request.__fusebox.fuseactionsDone,arguments.parsedFileInfo.parsedFile)>
			<cfthrow type="fusebox.badGrammar.recursiveDo" 
					message="Recursive do is illegal"
					detail="An attempt was made to execute a dynamic fuseaction '#arguments.parsedFileInfo.parsedFile#' that is already being executed, in fuseaction #arguments.myFusebox.getCurrentCircuit().getAlias()#.#arguments.myFusebox.getCurrentFuseaction().getName()#." />
		</cfif>
		<cfset request.__fusebox.fuseactionsDone[arguments.parsedFileInfo.parsedFile] = true />

		<cfset structAppend(variables,myFusebox.variables(),true) />
		
		<!---
			readonly lock protects against including the parsed file while
			another threading is writing it...
		--->
		<cflock name="#arguments.parsedFileInfo.lockName#" type="readonly" timeout="30">
			<cfif arguments.returnOutput>
				<cfsavecontent variable="output"><cfinclude template="#arguments.parsedFileInfo.parsedFile#" /></cfsavecontent>
			<cfelse>
				<cfinclude template="#arguments.parsedFileInfo.parsedFile#" />
			</cfif>
		</cflock>
		
		<cfset structAppend(myFusebox.variables(),variables,true) />
		
		<cfset structDelete(request.__fusebox.fuseactionsDone,arguments.parsedFileInfo.parsedFile) />
		
		<cfreturn output />
		
	</cffunction>
	
</cfcomponent>