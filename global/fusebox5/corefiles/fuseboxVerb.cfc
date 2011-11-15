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
<cfcomponent output="false" hint="I represent a verb that is implemented as part of a lexicon.">
	
	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="action" type="any" required="true" 
					hint="I am the enclosing fuseaction object." />
		<cfargument name="customVerb" type="string" required="true" 
					hint="I am the name of this (custom) verb." />
		<cfargument name="attributes" type="struct" required="true" 
					hint="I am the attributes for this verb." />
		<cfargument name="children" type="any" required="true" 
					hint="I am the XML representation of any children this verb has." />

		<cfset var ns = listFirst(arguments.customVerb,".:") />		
		<cfset var i = 0 />
		<cfset var verb = "" />
		<cfset var factory = arguments.action.getCircuit().getApplication().getFuseactionFactory() />
		
		<cfset variables.action = arguments.action />
		<cfset variables.attributes = arguments.attributes />
		<!--- we will create our children below --->
		<cfset variables.verb = listLast(arguments.customVerb,".:") />
		<cfset variables.children = structNew() />
		
		<cfset variables.factory = factory />
		<cfset variables.nChildren = arrayLen(arguments.children) />
		
		<cfloop from="1" to="#variables.nChildren#" index="i">
			<cfset verb = arguments.children[i].xmlName />
			<cfset variables.children[i] = factory.create(verb,
						variables.action,
							arguments.children[i].xmlAttributes,
								arguments.children[i].xmlChildren) />
		</cfloop>

		<cfset variables.fb41style = listLen(arguments.customVerb,".") eq 2 />
		<cfif variables.fb41style>
			<cfset variables.lexicon = variables.action.getCircuit().getApplication().getLexiconDefinition(ns) />
		<cfelse>
			<cfset variables.lexicon = variables.action.getCircuit().getLexiconDefinition(ns) />
		</cfif>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="compile" returntype="void" access="public" output="false" 
				hint="I compile a custom lexicon verb. I create the thread-safe context and perform the start and end execution, as well as compiling any children.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />
		<cfargument name="context" type="any" required="false" 
					hint="I am the context in which this verb is compiled. I can be omitted if the verb has no enclosing parent." />

		<!---
			the following is purely a device to allow nested custom verbs:
			we pass the struct reference into the lexicon compiler but then we
			fill in the fields here *afterwards* - relies on pass by reference!
			because we are recursive, we need to create a new lexicon compiler
			on each 'call' of the (static) compiler (i.e., this method)
			trust me! -- sean corfield
		--->
		<cfset var verbInfo = structNew() />
		<cfset var compiler = variables.factory.createLexiconCompiler()
				.init(arguments.writer,verbInfo,variables) />
		<cfset var i = 0 />

		<cfset verbInfo.lexicon = variables.lexicon.namespace />
		<cfset verbInfo.lexiconVerb = variables.verb />
		<cfset verbInfo.attributes = variables.attributes />
		<!---
			change to FB41 lexicons (but needed for FB5):
				circuit - alias of current circuit
				fuseaction - name of current fuseaction
				action - fuseaction object for more complex usage
		--->
		<cfset verbInfo.circuit = variables.action.getCircuit().getAlias() />
		<cfset verbInfo.fuseaction = variables.action.getName() />
		<cfset verbInfo.action = variables.action />
		
		<cfif variables.fb41style>

			<!--- FB41: just compile the lexicon once with no executionMode --->
			<cfset compiler.compile() />

		<cfelse>

			<!---
				FB5 has new fields in verbInfo:
				skipBody - false, can be set to true by start tag to skip compilation of child tags
				hasChildren - true if there are nested tags, else false
				parent - present if we are nested (the verbInfo of the parent tag)
				executionMode - start|inactive|end, just like custom tags
			--->
			<cfset verbInfo.skipBody = false />
			<cfset verbInfo.hasChildren = variables.nChildren neq 0 />
			<!---
				Fusebox 5.1: make children available to nested verbs.
				This actually opens up some frightening possibilities
				which I'd prefer not to document but no doubt someone
				will discover what you can do...
				This was originally done for ticket 180 to allow <if>
				to verify its own children to make sure on <true> and
				<false> are present.
			--->
			<cfset verbInfo.nChildren = variables.nChildren />
			<cfset verbInfo.children = variables.children />

			<cfif structKeyExists(arguments,"context")>
				<cfset verbInfo.parent = arguments.context />
			</cfif>

			<cfset verbInfo.executionMode = "start" />
			<cfset compiler.compile() />

			<cfif structKeyExists(verbInfo,"skipBody") and isBoolean(verbInfo.skipBody) and verbInfo.skipBody>
				<!--- the verb decided not to compile its children --->
			<cfelse>
				<cfif variables.nChildren gt 0>
					<cfset verbInfo.executionMode = "inactive" />
					<cfloop from="1" to="#variables.nChildren#" index="i">
						<cfset variables.children[i].compile(arguments.writer,verbInfo) />
					</cfloop>		
				</cfif>
			</cfif>

			<cfset verbInfo.executionMode = "end" />
			<cfset compiler.compile() />

		</cfif>
		
		<cfset variables.factory.freeLexiconCompiler(compiler) />

	</cffunction>

	<cffunction name="getNamespace" returntype="string" access="public" output="false"
				hint="I return the namespace for this verb.">

		<!--- make sure we hide the Fuebox lexicon name --->
		<cfif variables.factory.getBuiltinLexicon().namespace is variables.lexicon.namespace>
			<cfreturn "" />
		<cfelse>
			<cfreturn variables.lexicon.namespace />
		</cfif>

	</cffunction>	
	
	<cffunction name="getVerb" returntype="string" access="public" output="false">

		<cfreturn variables.verb />

	</cffunction>
	
</cfcomponent>
