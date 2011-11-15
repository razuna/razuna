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
<cfcomponent output="false" hint="I am the representation of the do and fuseaction verbs.">
	
	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="action" type="any" required="true" 
					hint="I am the enclosing fuseaction object." />
		<cfargument name="attributes" type="struct" required="true" 
					hint="I am the attributes for this verb." />
		<cfargument name="children" type="any" required="true" 
					hint="I am the XML representation of any children this verb has." />
		<cfargument name="verb" type="string" required="true" 
					hint="I am the name of this verb." />
					
		<cfset var nAttrs = 1 />
		
		<cfset variables.action = arguments.action />
		<cfset variables.attributes = structNew() />
		<cfset variables.children = arguments.children />
		<cfset variables.numChildren = arrayLen(variables.children) />
		<cfset variables.verb = arguments.verb />
		
		<!---
			validate the attributes:
			action - required
			append - boolean - optional
			prepend - boolean - optional
			overwrite - boolean - optional
			contentvariable - optional
		--->
		<cfif structKeyExists(arguments.attributes,"action")>
			<cfset variables.attributes.action = arguments.attributes.action />
		<cfelse>
			<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
					message="Required attribute is missing"
					detail="The attribute 'action' is required, for a '#variables.verb#' verb in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
		</cfif>
		<cfif variables.verb is "fuseaction" and listLen(variables.attributes.action,".") lt 2>
			<!--- illegal: there is no circuit associated with a (global) action --->
			<cfthrow type="fusebox.badGrammar.invalidAttributeValue"
					message="Attribute has invalid value" 
					detail="The attribute 'action' must be a fully-qualified fuseaction, for a 'fuseaction' verb in a global pre/post process." />
		</cfif>		
		
		<cfif structKeyExists(arguments.attributes,"append")>
			<cfset variables.attributes.append = arguments.attributes.append />
			<cfset nAttrs = nAttrs + 1 />
			<cfif listFind("true,false,yes,no",variables.attributes.append) eq 0>
				<cfthrow type="fusebox.badGrammar.invalidAttributeValue"
						message="Attribute has invalid value"
						detail="The attribute 'append' must either be ""true"" or ""false"", for a '#variables.verb#' verb in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
			</cfif>
			<cfif not structKeyExists(arguments.attributes,"contentvariable")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'contentvariable' is required when the attribute 'append' is present, for a '#variables.verb#' verb in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
			</cfif>
		<cfelse>
			<cfset variables.attributes.append = false />
		</cfif>

		<cfif structKeyExists(arguments.attributes,"prepend")>
			<cfset variables.attributes.prepend = arguments.attributes.prepend />
			<cfset nAttrs = nAttrs + 1 />
			<cfif listFind("true,false,yes,no",variables.attributes.prepend) eq 0>
				<cfthrow type="fusebox.badGrammar.invalidAttributeValue"
						message="Attribute has invalid value"
						detail="The attribute 'prepend' must either be ""true"" or ""false"", for a '#variables.verb#' verb in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
			</cfif>
			<cfif not structKeyExists(arguments.attributes,"contentvariable")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'contentvariable' is required when the attribute 'append' is present, for a '#variables.verb#' verb in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
			</cfif>
		<cfelse>
			<cfset variables.attributes.prepend = false />
		</cfif>

		<cfif structKeyExists(arguments.attributes,"overwrite")>
			<cfset variables.attributes.overwrite = arguments.attributes.overwrite />
			<cfset nAttrs = nAttrs + 1 />
			<cfif listFind("true,false,yes,no",variables.attributes.overwrite) eq 0>
				<cfthrow type="fusebox.badGrammar.invalidAttributeValue"
						message="Attribute has invalid value"
						detail="The attribute 'overwrite' must either be ""true"" or ""false"", for a '#variables.verb#' verb in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
			</cfif>
			<cfif not structKeyExists(arguments.attributes,"contentvariable")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'contentvariable' is required when the attribute 'append' is present, for a '#variables.verb#' verb in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
			</cfif>
		<cfelse>
			<cfset variables.attributes.overwrite = true />
		</cfif>

		<cfif structKeyExists(arguments.attributes,"contentvariable")>
			<cfset variables.attributes.contentvariable = arguments.attributes.contentvariable />
			<cfset nAttrs = nAttrs + 1 />
		</cfif>

		<cfif variables.action.getCircuit().getApplication().strictMode and structCount(arguments.attributes) neq nAttrs>
			<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
					message="Unexpected attributes"
					detail="Unexpected attributes were found in a '#variables.verb#' verb in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
		</cfif>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="compile" returntype="void" access="public" output="false" 
				hint="I compile this do/fuseaction verb.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />

		<cfset var i = 0 />
		<cfset var n = 0 />
		<cfset var app = variables.action.getCircuit().getApplication() />
		<cfset var plugins = app.pluginPhases />
		<cfset var c = "" />
		<cfset var f = "" />
		<cfset var cDotF = "" />
		<cfset var old_c = "" />
		<cfset var old_f = "" />
		<cfset var circuits = app.circuits />
		<cfset var needTryOnFuseaction = false />

		<cfif listLen(variables.attributes.action,".") gte 2>
			<!--- action is a circuit.fuseaction pair somewhere --->
			<cfset f = listLast(variables.attributes.action,".") />
			<cfset c = left(variables.attributes.action,len(variables.attributes.action)-len(f)-1) />
			<cfset cDotF = variables.attributes.action />
		<cfelse>
			<cfset c = variables.action.getCircuit().getAlias() />
			<cfset f = variables.attributes.action />
			<cfset cDotF = c & "." & f />
		</cfif>
		
		<cfif structKeyExists(request.__fusebox.fuseactionsDone,cDotF)>
			<cfthrow type="fusebox.badGrammar.recursiveDo" 
					message="Recursive do is illegal"
					detail="An attempt was made to compile a fuseaction '#cDotF#' that is already being compiled, in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
		</cfif>
		<cfset request.__fusebox.fuseactionsDone[cDotF] = true />
		
		<cfset arguments.writer.rawPrintln('<!--- #variables.verb# action="#variables.attributes.action#" --->') />
		<cfif app.debug>
			<cfset arguments.writer.rawPrintln('<' & 'cfset myFusebox.trace("Runtime","&lt;#variables.verb# action=""#variables.attributes.action#""/&gt;") >') />
		</cfif>
		<cfset old_c = arguments.writer.setCircuit(c) />
		<cfset old_f = arguments.writer.setFuseaction(f) />
		
		<cfif structKeyExists(plugins,"fuseactionException") and
				arrayLen(plugins["fuseactionException"]) gt 0 and
				not request.__fusebox.SuppressPlugins>
			<cfset needTryOnFuseaction = true />
			<cfset arguments.writer.rawPrintln("<cftry>") />
		</cfif>
		
		<cfif structKeyExists(plugins,"preFuseaction")>
			<cfset n = arrayLen(plugins["preFuseaction"]) />
			<cfloop from="1" to="#n#" index="i">
				<cfset plugins["preFuseaction"][i].compile(arguments.writer) />
			</cfloop>
		</cfif>
		
		<cfif variables.numChildren gt 0>
			<cfset enterStackFrame(arguments.writer) />
		</cfif>
		
		<cfif structKeyExists(variables.attributes,"contentvariable")>
			<cfif not variables.attributes.overwrite>
				<cfset arguments.writer.println('<cfif not isDefined("#variables.attributes.contentvariable#")>') />
			</cfif>
			<cfif variables.attributes.append or variables.attributes.prepend>
				<cfset arguments.writer.println('<cfparam name="#variables.attributes.contentvariable#" default="">') />
			</cfif>
			<cfset arguments.writer.println('<cfsavecontent variable="#variables.attributes.contentvariable#">') />
			<cfif variables.attributes.append>
				<cfset arguments.writer.println('<' & 'cfoutput>###variables.attributes.contentvariable###</' & 'cfoutput>') />
			</cfif>
		</cfif>

		<cfif listLen(variables.attributes.action,".") gte 2>

			<cfif structKeyExists(circuits,c)>

				<cfif structKeyExists(circuits[c].fuseactions,f)>

					<!--- if not in the same circuit, check access is not private --->
					<cfif c is not variables.action.getCircuit().getAlias()>

						<cfif circuits[c].fuseactions[f].getAccess() is "private">

							<cfthrow type="fusebox.invalidAccessModifier" 
									message="invalid access modifier" 
									detail="The fuseaction '#c#.#f#' has an access modifier of private and can only be called from within its own circuit. Use an access modifier of internal or public to make it available outside its immediate circuit.">

						</cfif>

					</cfif>
					
				<!--- ticket 309 - remove fuseaction check prior to compile so that implicit circuits work --->
				
				</cfif>

			<cfelseif not variables.action.getCircuit().getApplication().allowImplicitCircuits>

				<cfthrow type="fusebox.undefinedCircuit" 
						message="undefined Circuit" 
						detail="You specified a Circuit of #c# which is not defined." />

			</cfif>

			<cfset variables.action.getCircuit().getApplication().compile(arguments.writer,c,f) />

		<cfelse>

			<!--- action is a fuseaction in this same circuit --->
			<cfif not structKeyExists(variables.action.getCircuit().fuseactions,f)>
				<cfthrow type="fusebox.undefinedFuseaction" 
						message="undefined Fuseaction" 
						detail="You specified a Fuseaction of #f# which is not defined in Circuit #c#." />
			</cfif>

			<cfset variables.action.getCircuit().compile(arguments.writer,f) />

		</cfif>
		
		<cfif structKeyExists(variables.attributes,"contentvariable")>
			<cfif variables.attributes.prepend>
				<cfset arguments.writer.println('<' & 'cfoutput>###variables.attributes.contentvariable###</' & 'cfoutput>') />
			</cfif>
			<cfset arguments.writer.println('</cfsavecontent>') />
			<cfif not variables.attributes.overwrite>
				<cfset arguments.writer.println('</cfif>') />
			</cfif>
		</cfif>

		<cfif variables.numChildren gt 0>
			<cfset leaveStackFrame(arguments.writer) />
		</cfif>
		
		<cfif structKeyExists(plugins,"postFuseaction")>
			<cfset n = arrayLen(plugins["postFuseaction"]) />
			<cfloop from="1" to="#n#" index="i">
				<cfset plugins["postFuseaction"][i].compile(arguments.writer) />
			</cfloop>
		</cfif>

		<cfif needTryOnFuseaction>
			<cfset n = arrayLen(plugins["fuseactionException"]) />
			<cfloop from="1" to="#n#" index="i">
				<cfset plugins["fuseactionException"][i].compile(arguments.writer) />
			</cfloop>
			<cfset arguments.writer.rawPrintln("</cftry>") />
		</cfif>

		<cfset arguments.writer.setFuseaction(old_f) />
		<cfset arguments.writer.setCircuit(old_c) />

		<cfset structDelete(request.__fusebox.fuseactionsDone,cDotF) />
		
	</cffunction>
	
	<cffunction name="enterStackFrame" returntype="void" access="private" output="false" 
				hint="I generate code to create a new stack frame and push the scoped variables.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />
		
		<cfset var i = 0 />
		<cfset var child = 0 />
		<cfset var match1 = 0 />
		<cfset var match2 = 0 />
		<cfset var nameLen = 0 />
		
		<cfset arguments.writer.rawPrintln('<cfset myFusebox.enterStackFrame() >') />
		<cfloop from="1" to="#variables.numChildren#" index="i">
			<cfset child = variables.children[i] />
			<!--- validate the child: it must be <parameter> and have both name= and value= --->
			<cfif child.xmlName is "parameter">
				<cfif not structKeyExists(child.xmlAttributes,"name")>
					<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
							message="Required attribute is missing"
							detail="The attribute 'name' is required, for a 'parameter' verb in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
				</cfif>
				<cfset match1 = REFind("[A-Za-z0-9_]*",child.xmlAttributes.name,1,true) />
				<cfset match2 = REFind("[A-Za-z0-9_]*\.[A-Za-z0-9_]*",child.xmlAttributes.name,1,true) />
				<cfset nameLen = len(child.xmlAttributes.name) />
				<cfif match1.pos[1] eq 1 and match1.len[1] eq nameLen>
					<!--- simple varname: patch up XML to make leaveStackFrame() simpler --->
					<cfset child.xmlAttributes.name = "variables." & child.xmlAttributes.name />
				<cfelseif match2.pos[1] eq 1 and match2.len[1] eq nameLen>
					<!--- scoped varname.varname: nothing to patch up --->
				<cfelse>
					<cfthrow type="fusebox.badGrammar.invalidAttributeValue"
							message="Attribute has invalid value"
							detail="The attribute 'name' must be a simple variable name, optionally qualified by a scope name, for a 'parameter' verb in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
				</cfif>
				<cfset arguments.writer.rawPrintln('<' & 'cfif isDefined("#child.xmlAttributes.name#")><' &
							'cfset myFusebox.stack["#child.xmlAttributes.name#"] = #child.xmlAttributes.name# ></' & 'cfif>') />
				<cfif structKeyExists(child.xmlAttributes,"value")>
					<cfset arguments.writer.rawPrintln('<' & 'cfset #child.xmlAttributes.name# = "#child.xmlAttributes.value#" >') />
				</cfif>
			<cfelse>
				<cfthrow type="fusebox.badGrammar.illegalVerb" 
						message="Illegal verb encountered" 
						detail="The '#child.xmlName#' verb is illegal inside a 'do' verb, in fuseaction #variables.action.getCircuit().getAlias()#.#variables.action.getName()#." />
			</cfif>
		</cfloop>
		
	</cffunction>
	
	<cffunction name="leaveStackFrame" returntype="void" access="private" output="false" 
				hint="I generate code to pop the scoped variables and drop the stack frame.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />
		
		<cfset var i = 0 />
		<cfset var child = 0 />
		<cfset var scope = "" />
		<cfset var qName = "" />
		
		<cfloop from="#variables.numChildren#" to="1" step="-1" index="i">
			<cfset child = variables.children[i] />
			<cfset arguments.writer.rawPrintln('<' & 'cfif structKeyExists(myFusebox.stack,"#child.xmlAttributes.name#")><' &
						'cfset #child.xmlAttributes.name# = myFusebox.stack["#child.xmlAttributes.name#"] ></' & 'cfif>') />
			<cfset scope = listFirst(child.xmlAttributes.name,".") />
			<cfset qName = listRest(child.xmlAttributes.name,".") />
			<cfset arguments.writer.rawPrintln('<' & 'cfif structKeyExists(myFusebox.stack,"#child.xmlAttributes.name#")><' &
							'cfset #child.xmlAttributes.name# = myFusebox.stack["#child.xmlAttributes.name#"] ><' &
							'cfelse><' & 
							'cfset structDelete(#scope#,"#qName#")></' & 'cfif>') />
		</cfloop>
		<cfset arguments.writer.rawPrintln('<cfset myFusebox.leaveStackFrame() >') />
		
	</cffunction>

	<cffunction name="getNamespace" returntype="string" access="public" output="false"
				hint="I return the namespace for this verb (which will be empty).">

		<cfreturn "" />

	</cffunction>	
	
	<cffunction name="getVerb" returntype="string" access="public" output="false">

		<cfreturn variables.verb />

	</cffunction>
	
</cfcomponent>
