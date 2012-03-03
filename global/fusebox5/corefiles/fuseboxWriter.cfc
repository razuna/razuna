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
<cfcomponent output="false" hint="I manage the creation of and writing to the parsed files.">

	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="fbApp" type="any" required="false" 
					hint="I am the fusebox application object. I am required but it's faster to specify that I am not required." />
		<cfargument name="myFusebox" type="any" required="false" 
					hint="I am the myFusebox data structure. I am required but it's faster to specify that I am not required." />
		
		<cfset variables.fuseboxApplication = arguments.fbApp />
		<cfset variables.myFusebox = arguments.myFusebox />
		<cfset variables.parsedDir = variables.fuseboxApplication.expandFuseboxPath(variables.fuseboxApplication.parsePath) />
		<cfset variables.phase = "" />
		<cfset variables.circuit = "" />
		<cfset variables.fuseaction = "" />
		<cfset variables.newline = chr(13) & chr(10) />
		
		<cfif not directoryExists(variables.parsedDir)>
			<cflock name="#variables.parsedDir#" type="exclusive" timeout="30">
				<cfif not directoryExists(variables.parsedDir)>
					<cftry>
						<cfdirectory action="create" directory="#variables.parsedDir#" mode="777" />
					<cfcatch type="any">
						<cfthrow type="fusebox.missingParsedDirException"
							message="The 'parsed' directory in the application root directory is missing, and could not be created"
							detail="You must manually create this directory, and ensure that CF has the ability to write and change files within the directory."
							extendedinfo="#cfcatch.detail#" />
					</cfcatch>
					</cftry>
				</cfif>
			</cflock>
		</cfif>

		<cfset reset() />

		<cfreturn this />

	</cffunction>
	
	<cffunction name="getMyFusebox" returntype="any" access="public" output="false">
	
		<cfreturn variables.myFusebox />
		
	</cffunction>

	<cffunction name="reset" returntype="void" access="public" output="false" 
				hint="I reset the phase, circuit and fuseaction as well as initializing the file content object.">

		<cfset variables.lastPhase = "" />
		<cfset variables.lastCircuit = "" />
		<cfset variables.lastFuseaction = "" />
		<!--- watch out for hosts that have createObject("java") disabled - this will be slow but it will work --->
		<cftry>
			<cfset variables.content = createObject("java","java.lang.StringBuffer").init() />
		<cfcatch type="any">
			<cfset variables.content = createObject("component","FakeStringBuffer").init() />
		</cfcatch>
		</cftry>

	</cffunction>	

	<cffunction name="open" returntype="void" access="public" output="false" 
				hint="I 'open' the parsed file. In fact I just setup the writing process. The file is only created when this writer object is 'closed'.">
		<cfargument name="filename" type="string" required="true" 
					hint="I am the name of the parsed file to be created." />
		
		<cfset variables.filename = arguments.filename />
		<cfset reset() />
		<cfset rawPrintln('<cfsetting enablecfoutputonly="true" />') />
		<cfset rawPrintln('<cfprocessingdirective pageencoding="#variables.fuseboxApplication.characterEncoding#" />') />
		
	</cffunction>
	
	<cffunction name="close" returntype="void" access="public" output="false" 
				hint="I 'close' the parsed file and write it to disk.">
		<cfargument name="parsedFileCache" type="struct" required="true" 
					hint="I am a cache of parsed file text hash values." />
		
		<cfset var parsedText = variables.content.toString() />
		<cfset var parsedHash = hash(parsedText) />
		
		<cfif variables.fuseboxApplication.conditionalParse>
			<cfif fileExists(variables.parsedDir & "/" & variables.filename) and
					structKeyExists(arguments.parsedFileCache,variables.filename) and
					parsedHash is arguments.parsedFileCache[variables.filename]>
				<cfif variables.fuseboxApplication.debug>
					<cfset getMyFusebox().trace("Compiler","Parsed file '#variables.filename#' is unchanged and was not overwritten") />
				</cfif>
				<cfreturn />
			<cfelse>
				<cfif variables.fuseboxApplication.debug>
					<cfset getMyFusebox().trace("Compiler","Parsed file '#variables.filename#' changed or did not exist") />
				</cfif>
			</cfif>
		</cfif>
		<cfset arguments.parsedFileCache[variables.filename] = parsedHash />
		
		<cfset rawPrintln('<cfsetting enablecfoutputonly="false" />') />
		<cftry>
			<cffile action="write" file="#variables.parsedDir#/#variables.filename#"
					output="#parsedText#"
					charset="#variables.fuseboxApplication.characterEncoding#" />
		<cfcatch type="any">
			<cfthrow type="fusebox.errorWritingParsedFile" 
					message="An Error during write of Parsed File or Parsing Directory not found." 
					detail="Attempting to write the parsed file '#variables.filename#' threw an error. This can also occur if the parsed file directory cannot be found."
					extendedinfo="#cfcatch.detail#" />
		</cfcatch>
		</cftry>
		
	</cffunction>
	
	<cffunction name="setPhase" returntype="any" access="public" output="false" 
				hint="I remember the currently executing plugin phase.">
		<cfargument name="phase" type="any" required="false" 
					hint="I am the name of the current phase. I am required but it's faster to specify that I am not required." />
		
		<cfset var p = variables.phase />
		
		<cfset variables.phase = arguments.phase />
		
		<cfreturn p />
		
	</cffunction>
	
	<cffunction name="setCircuit" returntype="any" access="public" output="false" 
				hint="I remember the currently executing circuit alias.">
		<cfargument name="circuit" type="any" required="false" 
					hint="I am the name of the current circuit. I am required but it's faster to specify that I am not required." />
		
		<cfset var c = variables.circuit />
		
		<cfset variables.circuit = arguments.circuit />
		
		<cfreturn c />
		
	</cffunction>
	
	<cffunction name="setFuseaction" returntype="any" access="public" output="false" 
				hint="I remember the currently executing fuseaction name.">
		<cfargument name="fuseaction" type="any" required="false" 
					hint="I am the name of the current fuseaction. I am required but it's faster to specify that I am not required." />
		
		<cfset var f = variables.fuseaction />
		
		<cfset variables.fuseaction = arguments.fuseaction />
		
		<cfreturn f />
		
	</cffunction>
	
	<cffunction name="print" returntype="void" access="public" output="false" 
				hint="I print a string to the parsed file. I set the phase, circuit and fuseaction variables if necessary in the myFusebox structure.">
		<cfargument name="text" type="any" required="false" 
					hint="I am the string to be printed. I am required but it's faster to specify that I am not required." />
		
		<cfif variables.lastPhase is not variables.phase>
			<cfset rawPrintln('<cfset myFusebox.thisPhase = "#variables.phase#">') />
			<cfset variables.lastPhase = variables.phase />
		</cfif>
		<cfif variables.lastCircuit is not variables.circuit>
			<cfset rawPrintln('<cfset myFusebox.thisCircuit = "#variables.circuit#">') />
			<cfset variables.lastCircuit = variables.circuit />
		</cfif>
		<cfif variables.lastFuseaction is not variables.fuseaction>
			<cfset rawPrintln('<cfset myFusebox.thisFuseaction = "#variables.fuseaction#">') />
			<cfset variables.lastFuseaction = variables.fuseaction />
		</cfif>
		<cfset variables.content.append(arguments.text) />
		
	</cffunction>
	
	<cffunction name="println" returntype="void" access="public" output="false" 
				hint="I print a string to the parsed file, followed by a newline. I set the phase, circuit and fuseaction variables if necessary in the myFusebox structure.">
		<cfargument name="text" type="any" required="false" 
					hint="I am the string to be printed. I am required but it's faster to specify that I am not required." />
		
		<cfset print(arguments.text) />
		<cfset variables.content.append(variables.newline) />
		
	</cffunction>
	
	<cffunction name="rawPrint" returntype="void" access="public" output="false" 
				hint="I print a string to the parsed file, without setting any variables.">
		<cfargument name="text" type="any" required="false" 
					hint="I am the string to be printed. I am required but it's faster to specify that I am not required." />

		<cfset variables.content.append(arguments.text) />

	</cffunction>
	
	<cffunction name="rawPrintln" returntype="void" access="public" output="false" 
				hint="I print a string to the parsed file, followed by a newline, without setting any variables.">
		<cfargument name="text" type="any" required="false" 
					hint="I am the string to be printed. I am required but it's faster to specify that I am not required." />

		<cfset variables.content.append(arguments.text).append(variables.newline) />

	</cffunction>
		
</cfcomponent>
