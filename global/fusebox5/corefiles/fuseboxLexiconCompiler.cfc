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
<cfcomponent output="false" 
			hint="I compile a lexicon verb. I am created for each verb that needs to be compiled and I provide the thread-safe context in which that verb is compiled. That includes the various fb_* methods used to write to the parsed file.">

	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />
		<cfargument name="verbInfo" type="any" required="false" 
					hint="I am the verb compilation context. I am required but it's faster to specify that I am not required." />
		<cfargument name="lexiconInfo" type="any" required="false" 
					hint="I am the lexicon definition that supports this verb. I am required but it's faster to specify that I am not required." />
		
		<cfset variables.fb_writer = arguments.writer />
		<cfset variables.fb_ = structNew() />
		<cfset variables.fb_.verbInfo = arguments.verbInfo />
		<cfset variables.lexiconInfo = arguments.lexiconInfo />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="compile" returntype="void" access="public" output="false" 
				hint="I compile a lexicon verb by including its implementation file.">

		<cfset var info = variables.lexiconInfo />
		<cfset var lexiconFile = info.lexicon.path />
		
		<cfset lexiconFile = lexiconFile & info.verb />
		<cfset lexiconFile = lexiconFile & "." & "cfm" />
		
		<cftry>
			<cfinclude template="#lexiconFile#" />
			<cfcatch type="missingInclude">
				<cfset fb_throw("fusebox.badGrammar.missingImplementationException",
								"Bad Grammar verb in circuit file",
								"The implementation file for the '#info.verb#' verb from the '#info.lexicon.namespace#'" &
									" custom lexicon could not be found.  It is used in the '#variables.fb_.verbInfo.circuit#.#variables.fb_.verbInfo.fuseaction#' fuseaction.") />
			</cfcatch>
		</cftry>
		
	</cffunction>
	
	<!---
		FB55: added this to workaround path issues when a verb needs a component
		this was specifically added to support <include ... circuit= ... /> when
		implicit circuits are allowed and the named circuit does not already exist
	--->
	<cffunction name="__makeImplicitCircuit" returntype="any" access="private" output="false"
				hint="I return an implicit circuit for any verb that has a circuit= attribute.">
		
		<cfreturn createObject("component","fuseboxImplicitCircuit")
					.init(variables.fb_.app,
						variables.fb_.verbInfo.attributes.circuit,
						variables.fb_writer.getMyFusebox()) />
		
	</cffunction>
	
	<cffunction name="fb_appendLine" output="false" returntype="void" 
				hint="I append a line to the parsed file.">
		<cfargument name="lineContent" type="string" required="true" 
					hint="I am the line of text to append." />
		<cfset variables.fb_writer.println(arguments.lineContent) />
	</cffunction>
	
	<cffunction name="fb_appendIndent" output="false" returntype="void" 
				hint="I am a no-op provided for backward compatibility.">
	</cffunction>
	
	<cffunction name="fb_appendSegment" output="false" returntype="void" 
				hint="I append a segment of text to the parsed file.">
		<cfargument name="segmentContent" type="string" required="true" 
					hint="I am the segment of text to append." />
		<cfset variables.fb_writer.print(segmentContent) />
	</cffunction>
	
	<cffunction name="fb_appendNewline" output="false" returntype="void" 
				hint="I append a newline to the parsed file.">
		<cfset variables.fb_writer.println("") />
	</cffunction>
	
	<cffunction name="fb_increaseIndent" output="false" returntype="void" 
				hint="I am a no-op provided for backward compatibility.">
	</cffunction>
	
	<cffunction name="fb_decreaseIndent" output="false" returntype="void" 
				hint="I am a no-op provided for backward compatibility.">
	</cffunction>
	
	<cffunction name="fb_throw" output="false" returntype="void" 
				hint="I throw the specified exception.">
		<cfargument name="type" type="string" required="true" 
					hint="I am the type of exception to throw." />
		<cfargument name="message" type="string" required="true" 
					hint="I am the message to include in the thrown exception." />
		<cfargument name="detail" type="string" required="true" 
					hint="I am the detail to include in the thrown exception." />
		
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#" />

	</cffunction>
	
</cfcomponent>
