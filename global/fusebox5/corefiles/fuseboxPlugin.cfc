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
<cfcomponent output="false" hint="I represent a plugin declaration.">

	<cffunction name="init" returntype="fuseboxPlugin" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="phase" type="string" required="true" 
					hint="I am the phase with which this plugin is associated." />
		<cfargument name="pluginXML" type="any" required="true" 
					hint="I am the XML representation of this plugin's declaration." />
		<cfargument name="fbApp" type="fuseboxApplication" required="true" 
					hint="I am the fusebox application object." />
		<cfargument name="lexicons" type="struct" required="true" 
					hint="I am the lexicons declared in the fusebox.xml file that are available as custom attributes." />
	
		<cfset var i = 0 />
		<cfset var n = arrayLen(arguments.pluginXML.xmlChildren) />
		<cfset var attr = 0 />
		<cfset var ns = "" />
		<cfset var verbChildren = arrayNew(1) />
		<cfset var factory = arguments.fbApp.getFuseactionFactory() />
		<cfset var ext = "." & arguments.fbApp.scriptFileDelimiter />
		
		<cfif arguments.pluginXML.xmlName is "plugin">
		
			<cfif not structKeyExists(arguments.pluginXML.xmlAttributes,"name")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'name' is required, for a '#arguments.phase#' plugin declaration in fusebox.xml." />
			</cfif>
			
			<cfset variables.name = arguments.pluginXML.xmlAttributes.name />
			<cfset variables.fuseboxApplication = arguments.fbApp />
			<cfset variables.customAttribs = structNew() />
	
			<cfif not structKeyExists(arguments.pluginXML.xmlAttributes,"template")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'template' is required, for the '#getName()#' plugin declaration in fusebox.xml." />
			</cfif>
	
			<cfset variables.phase = arguments.phase />

			<cfset this.path = arguments.fbApp.getPluginsPath() />

			<cfif structKeyExists(arguments.pluginXML.xmlAttributes,"path")>
				<cfif left(arguments.pluginXML.xmlAttributes.path,1) is "/">
					<!--- path is absolute, ignore normal plugins path --->
					<cfset this.path = arguments.fbApp.normalizePartialPath(arguments.pluginXML.xmlAttributes.path) />
				<cfelse>
					<cfset this.path = this.path & arguments.fbApp.normalizePartialPath(arguments.pluginXML.xmlAttributes.path) />
				</cfif>
			</cfif>
			
			<!--- look for any valid custom attributes --->
			<cfloop collection="#arguments.pluginXML.xmlAttributes#" item="attr">
				<cfswitch expression="#attr#">

				<cfcase value="name,template,path">
					<!--- already processed --->
				</cfcase>

				<cfdefaultcase>

					<cfif listLen(attr,":") eq 2>
						<!--- looks like a custom attribute: --->
						<cfset ns = listFirst(attr,":") />
						<cfif structKeyExists(arguments.lexicons,ns)>
							<cfset customAttribs[ns][listLast(attr,":")] = arguments.pluginXML.xmlAttributes[attr] />
						<cfelse>
							<cfthrow type="fusebox.badGrammar.undeclaredNamespace" 
									message="Undeclared lexicon namespace" 
									detail="The lexicon prefix '#ns#' was found on a custom attribute in the '#getName()#' plugin declaration in fusebox.xml but no such lexicon namespace has been declared." />
						</cfif>
	
					<cfelseif arguments.fbApp.strictMode>
						<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
								message="Unexpected attributes"
								detail="Unexpected attribute '#attr#' found in the '#getName()#' plugin declaration in fusebox.xml." />
					</cfif>
					
				</cfdefaultcase>

				</cfswitch>
			</cfloop>
			
			<cfset variables.template = arguments.pluginXML.xmlAttributes.template />
			<cfif len(variables.template) lt 4 or right(variables.template,4) is not ext>
				<cfset variables.template = variables.template & ext />
			</cfif>
			<cfif left(this.path,1) is "/">
				<cfset this.rootpath =
						arguments.fbApp.relativePath(arguments.fbApp.expandFuseboxPath(this.path),arguments.fbApp.getApplicationRoot()) />
			<cfelse>
				<cfset this.rootpath =
						arguments.fbApp.relativePath(arguments.fbApp.getApplicationRoot() &
														this.path,arguments.fbApp.getApplicationRoot()) />
			</cfif>
			
			<cfset this.rootpath = arguments.fbApp.getCanonicalPath(this.rootpath) />
			
			<cfset variables.parameters = arguments.pluginXML.xmlChildren />
			<cfset variables.paramVerbs = structNew() />
			<cfloop from="1" to="#n#" index="i">
				
				<cfif variables.parameters[i].xmlName is not "parameter">
					<cfthrow type="fusebox.badGrammar.illegalDeclaration"
							message="Parameter expected in plugin declaration"
							detail="A 'plugin' declaration contained '#variables.parameters[i].xmlName#' but only 'parameter' is allowed, in fusebox.xml." />
				</cfif>
				<cfif not structKeyExists(variables.parameters[i].xmlAttributes,"name")>
					<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
							message="Required attribute is missing"
							detail="The attribute 'name' is required, for a 'parameter' to the '#getName()#' plugin declaration in fusebox.xml." />
				</cfif>

				<cfif not structKeyExists(variables.parameters[i].xmlAttributes,"value")>
					<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
							message="Required attribute is missing"
							detail="The attribute 'value' is required, for a 'parameter' to the '#getName()#' plugin declaration in fusebox.xml." />
				</cfif>

				<cfif arguments.fbApp.strictMode and structCount(variables.parameters[i].xmlAttributes) neq 2>
					<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
							message="Unexpected attributes"
							detail="Unexpected attributes were found in the '#variables.parameters[i].xmlAttributes.name#' parameter of the '#getName()#' plugin declaration in fusebox.xml." />
				</cfif>

				<cfset attr = structNew() />
				<cfset attr.name = "myFusebox.plugins.#getName()#.parameters." & variables.parameters[i].xmlAttributes.name />
				<cfset attr.value = variables.parameters[i].xmlAttributes.value />
				<cfset variables.paramVerbs[i] = factory.create("set",this,attr,verbChildren) />

			</cfloop>
		<cfelse>
			<cfthrow type="fusebox.badGrammar.illegalDeclaration" 
					message="Illegal declaration" 
					detail="The XML entity '#arguments.pluginXML.xmlName#' was found where a plugin declaration was expected in fusebox.xml." />
		</cfif>
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="compile" returntype="void" access="public" output="false" 
				hint="I compile this plugin object.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />
		
		<cfset var i = 0 />
		<cfset var n = structCount(variables.paramVerbs) />
		<cfset var file = "" />
		<cfset var p = "" />
		
		<cfif request.__fusebox.SuppressPlugins>
			<cfreturn />
		</cfif>
		<cfswitch expression="#variables.phase#">
		<cfcase value="processError,fuseactionException">
			<cfif left(this.path,1) is "/">
				<cffile action="read" file="#variables.fuseboxApplication.expandFuseboxPath(this.path)##variables.template#"
						variable="file"
						charset="#variables.fuseboxApplication.characterEncoding#" />
			<cfelse>
				<cffile action="read" file="#variables.fuseboxApplication.getApplicationRoot()##this.path##variables.template#"
						variable="file"
						charset="#variables.fuseboxApplication.characterEncoding#" />
			</cfif>
			<cfset arguments.writer.rawPrintln(file) />
		</cfcase>
		<cfdefaultcase>
			<cfloop from="1" to="#n#" index="i">
				<cfset variables.paramVerbs[i].compile(arguments.writer) />
			</cfloop>
			<cfset p = arguments.writer.setPhase(variables.phase) />
			<cfset arguments.writer.println('<cfset myFusebox.thisPlugin = "#getName()#"/>') />
			<cfset arguments.writer.print('<' & 'cfoutput><' & 'cfinclude template=') />
			<cfif left(this.path,1) is "/">
				<cfset arguments.writer.print('"#this.path##variables.template#"') />
			<cfelse>
				<cfset arguments.writer.print('"#variables.fuseboxApplication.parseRootPath##this.path##variables.template#"') />
			</cfif>
			<cfset arguments.writer.println('/><' & '/cfoutput>') />
			<cfset arguments.writer.setPhase(p) />
		</cfdefaultcase>
		</cfswitch>

	</cffunction>
	
	<cffunction name="getName" returntype="string" access="public" output="false" 
				hint="I return the name of the plugin.">
		
		<cfreturn variables.name />
		
	</cffunction>

	<cffunction name="getCircuit" returntype="any" access="public" output="false" 
				hint="I return the enclosing application object. This is an edge case to allow code that works with fuseactions to work with plugins too.">
	
		<cfreturn variables.fuseboxApplication />
	
	</cffunction>
	
	<cffunction name="getCustomAttributes" returntype="struct" access="public" output="false" 
				hint="I return the custom (namespace-qualified) attributes for this plugin tag.">
		<cfargument name="ns" type="string" required="true" 
					hint="I am the namespace prefix whose attributes should be returned." />
		
		<cfif structKeyExists(variables.customAttribs,arguments.ns)>
			<!--- we structCopy() this so folks can't poke values back into the metadata! --->
			<cfreturn structCopy(variables.customAttribs[arguments.ns]) />
		<cfelse>
			<cfreturn structNew() />
		</cfif>
		
	</cffunction>
	
</cfcomponent>
