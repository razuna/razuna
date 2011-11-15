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
<cfcomponent output="false" hint="I am a factory object that creates verb objects.">

	<cffunction name="init" returntype="fuseboxFactory" access="public" output="false" 
				hint="I am the constructor.">
		
		<cfset variables.lexCompPool = 0 />
		<cfset variables.verbLexPool = 0 />
		
		<cfset variables.fuseboxLexicon = structNew()/>
		<cfset variables.fuseboxLexicon.namespace = "$fusebox" />
		<cfset variables.fuseboxLexicon.path = "verbs/" />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="create" returntype="any" access="public" output="false" 
				hint="I create a verb object.">
		<cfargument name="verb" type="string" required="true" 
					hint="I am the name of the verb to create." />
		<cfargument name="action" type="any" required="true" 
					hint="I am the enclosing fuseaction object." />
		<cfargument name="attributes" type="struct" required="true" 
					hint="I am the attributes of this verb." />
		<cfargument name="children" type="any" required="true" 
					hint="I am the XML representation of this verb's children." />
		<cfargument name="global" type="boolean" default="false" 
					hint="I indicate whether this is part of a regular fuseaction (false) or a global fuseaction (true)." />
		
		<cfset var verbObject = "" />
		
		<!--- global pre/post process is a special case: --->
		<cfif arguments.global>
			<cfif listFind("do,fuseaction",arguments.verb)>
				<!--- this is OK, do is deprecated --->
				<cfif arguments.verb is "do" and arguments.action.getCircuit().getApplication().strictMode>
					<cfthrow type="fusebox.badGrammar.deprecated" 
							message="Deprecated feature"
							detail="Using the 'do' verb in a global pre/post process was deprecated in Fusebox 4.1." />
				</cfif>
			<cfelse>
				<!--- no other verbs are allowed --->
				<cfthrow type="fusebox.badGrammar.illegalVerb"
						message="Illegal verb encountered" 
						detail="The '#arguments.verb#' verb is illegal in a global pre/post process." />
			</cfif>
		<cfelse>
			<cfif listFind("fuseaction",arguments.verb)>
				<!--- verbs that are only legal in global pre/post process --->
				<cfthrow type="fusebox.badGrammar.illegalVerb"
						message="Illegal verb encountered" 
						detail="The '#arguments.verb#' verb is only legal in a global pre/post process." />
			</cfif>
		</cfif>
		<cfif listLen(arguments.verb,".:") eq 2>
			<!--- must be namespace.verb or namespace:verb --->
			<cfset verbObject = createObject("component","fuseboxVerb")
					.init(arguments.action, arguments.verb, arguments.attributes, arguments.children) />
		<cfelseif listFind("do,fuseaction",arguments.verb)>
			<!--- built-in verbs that cannot be implemented as a lexicon --->
			<cfset verbObject = createObject("component","fuseboxDoFuseaction")
					.init(arguments.action,arguments.attributes,arguments.children,arguments.verb) />
		<cfelse>
			<!--- builtin verb implemented as a lexicon --->
			<cfset verbObject = createObject("component","fuseboxVerb")
					.init(arguments.action, variables.fuseboxLexicon.namespace & ":" & arguments.verb,
							arguments.attributes, arguments.children) />
		</cfif>
		<cfreturn verbObject />
		
	</cffunction>
	
	<cffunction name="createLexiconCompiler" returntype="any" access="public" output="false" 
				hint="I return a lexicon compiler context (either from the pool or a newly created instance).">
	
		<cfset var obj = 0 />
		
		<cfif isSimpleValue(variables.lexCompPool)>
			<cfset obj = createObject("component","fuseboxLexiconCompiler") />
		<cfelse>
			<cfset obj = variables.lexCompPool />
			<cfset variables.lexCompPool = obj._next />
		</cfif>
		
		<cfreturn obj />
	
	</cffunction>
	
	<cffunction name="freeLexiconCompiler" returntype="void" access="public" output="false" 
				hint="I return the lexicon compiler context to the pool.">
		<cfargument name="lexComp" type="any" required="false"
					hint="I am the lexicon compiler context to be returned. I am required but it's faster to specify that I am not required." />
	
		<cfset arguments.lexComp._next = variables.lexCompPool />
		<cfset variables.lexCompPool = arguments.lexComp />
		
	</cffunction>
	
	<cffunction name="getBuiltinLexicon" returntype="any" access="public" output="false" 
				hint="I return the (magic) builtin lexicon.">
		
		<cfreturn variables.fuseboxLexicon />
		
	</cffunction>
	
</cfcomponent>
