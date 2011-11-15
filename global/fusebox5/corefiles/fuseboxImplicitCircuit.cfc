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
<cfcomponent hint="I represent an implicit circuit." output="false">
	
	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="fbApp" type="fuseboxApplication" required="true" 
					hint="I am the fusebox application object." />
		<cfargument name="alias" type="string" required="true" 
					hint="I am the circuit alias." />
		<cfargument name="myFusebox" type="myFusebox" required="true" 
					hint="I am the myFusebox data structure." />

		<cfset var traditionalCircuit = false />
		<cfset var circuitPrefix = "" />
		<cfset var circuitSearchPath =
					"controller/#arguments.alias#,model/#arguments.alias#,view/#arguments.alias#," &
					"#arguments.alias#/controller,#arguments.alias#/model,#arguments.alias#/view," &
					"#arguments.alias#" />
		
		<cfset variables.fuseboxApplication = arguments.fbApp />
		<cfset variables.alias = arguments.alias />
		
		<cfset variables.appPath = variables.fuseboxApplication.getApplicationRoot() />
		<cfset variables.fuseboxLexicon = variables.fuseboxApplication.getFuseactionFactory().getBuiltinLexicon() />

		<!--- ensure we don't reload this in the same request --->
		<cfset request.__fusebox.CircuitsLoaded[variables.alias] = true />

		<!---
			look for traditional circuit in MVC/alias or alias/MVC or just alias directories:
		--->
		<cfloop index="circuitPrefix" list="#circuitSearchPath#">
			<cfset traditionalCircuit =
					fileExists(variables.appPath & circuitPrefix & "/circuit.xml.cfm") or
					fileExists(variables.appPath & circuitPrefix & "/circuit.xml") />
			<cfif traditionalCircuit>
				<cfbreak />
			</cfif>
		</cfloop>
		<!---
			if we found a traditional circuit that simply wasn't declared,
			return a regular Fusebox 5.x style circuit object:
		--->
		<cfif traditionalCircuit>
			<cfif variables.fuseboxApplication.debug>
				<cfset arguments.myFusebox.trace("Compiler","Implicit #circuitPrefix#/circuit.xml(.cfm) identified") />
			</cfif>
			<cfreturn createObject("component","fuseboxCircuit")
						.init(variables.fuseboxApplication,
								getAlias(),
								circuitPrefix,
								"",
								arguments.myFusebox,
								true) />
		</cfif>

		<!---
			now we're off into convention over configuration territory...
		--->
		<cfset reload(arguments.myFusebox) />
			
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="reload" returntype="any" access="public" output="false" 
				hint="I reload the circuit file and build the in-memory structures from it.">
		<cfargument name="myFusebox" type="myFusebox" required="true" 
					hint="I am the myFusebox data structure." />

		<cfset var found = false />
		<cfset var path = "" />
		
		<cfset this.access = "public" />
		<cfset variables.fuseactionIsMethod = false />
		
		<!---
			in order of preference, we want to find:
			1. {MVC}/{alias}.cfc
				- this implies fuseactions are methods
			2. {MVC}/{alias}/
				- we can look for {fuseaction}.xml or {fuseaction}.cfm later
			3. {alias}/
				- we can look for {fuseaction}.xml or {fuseaction}.cfm later
		--->

		<cfloop index="path" list="controller/,model/,view/">

			<cfset variables.originalPath = path />
			<cfset variables.fullPath = variables.appPath & variables.originalPath />
			<cfset variables.relativePath = variables.fuseboxApplication.relativePath(variables.appPath,variables.fullPath) />
	
			<!--- if the CFC actually exists, see if we can figure out if it exists in a sensible place --->
			<cfif fileExists(variables.fullPath & getAlias() & ".cfc")>
				<cfset variables.dottedPath = variables.fuseboxApplication.locateCfc(variables.fullPath & getAlias() & ".cfc") />
				<cfif variables.dottedPath is not "">
					<cfset found = true />
					<cfset variables.fuseactionIsMethod = true />
					<cfif variables.fuseboxApplication.debug>
						<cfset arguments.myFusebox.trace("Compiler","Implicit component-as-circuit #variables.originalPath##getAlias()#.cfc identified") />
					</cfif>
					<cfbreak />
				</cfif>
			</cfif>

			<!--- first time through, access is public for controller - should change to internal for model / view circuits --->
			<cfset this.access = "internal" />
			
		</cfloop>

		<cfif not found>
			<!--- no CFCs so look for an MVC directory --->
			<cfset this.access = "public" />

			<cfloop index="path" list="controller/,model/,view/">
	
				<cfset variables.originalPath = path & getAlias() & "/" />
				<cfset variables.fullPath = variables.appPath & variables.originalPath />
				<cfset variables.relativePath = variables.fuseboxApplication.relativePath(variables.appPath,variables.fullPath) />
	
				<!--- MVC circuit directory? --->
				<cfif directoryExists(variables.fullPath)>
					<!--- looks like we have a candidate --->
					<cfset found = true />
					<cfif variables.fuseboxApplication.debug>
						<cfset arguments.myFusebox.trace("Compiler","Implicit circuit #variables.originalPath# identified") />
					</cfif>
					<cfbreak />
				</cfif>
				
				<!--- first time through, access is public for controller - should change to internal for model / view circuits --->
				<cfset this.access = "internal" />
				
			</cfloop>

		</cfif>					
		
		<cfif not found>
			<!--- no MVC, what about just a directory? --->
			<cfset this.access = "public" />
			<cfset variables.originalPath = getAlias() & "/" />
			<cfset variables.fullPath = variables.appPath & variables.originalPath />
			<cfset variables.relativePath = variables.fuseboxApplication.relativePath(variables.appPath,variables.fullPath) />

			<cfif directoryExists(variables.fullPath)>

				<!--- ok, the directory exists --->
				<cfif variables.fuseboxApplication.debug>
					<cfset arguments.myFusebox.trace("Compiler","Implicit circuit #getAlias()# identified") />
				</cfif>

			<cfelse>

				<cfthrow type="fusebox.undefinedCircuit" 
						message="undefined Circuit" 
						detail="You specified a Circuit of #getAlias()# which is not defined." />

			</cfif>

		</cfif>
		
		<!--- we don't know what fuseactions an implicit circuit has --->
		<cfset this.fuseactions = structNew() />
		<cfset this.parent = "" />
		<cfset this.permissions = "" />
		<cfset this.path = variables.relativePath />
		<cfset this.rootPath = variables.fuseboxApplication.relativePath(variables.fullPath,variables.appPath) />
		<cfset this.timestamp = now() />

	</cffunction>
	
	<cffunction name="compile" returntype="void" access="public" output="false" 
				hint="I compile a given fuseaction within this circuit.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />
		<cfargument name="fuseaction" type="any" required="false" 
					hint="I am the name of the fuseaction to compile. I am required but it's faster to specify that I am not required." />
		<cfargument name="topLevel" type="boolean" default="false" 
					hint="I specify whether or not this is a top-level (public) request." />

		<cfset var f = arguments.writer.setFuseaction(arguments.fuseaction) />
		
		<cfif arguments.fuseaction is "prefuseaction" or arguments.fuseaction is "postfuseaction">
			<cfthrow type="fusebox.undefinedFuseaction" 
					message="undefined Fuseaction" 
					detail="You specified a Fuseaction of #arguments.fuseaction# which is uncallable in Circuit #getAlias()#." />
		</cfif>

		<!--- prefuseaction is handled internally to the circuit mechanism --->

		<cfif not structKeyExists(this.fuseactions,arguments.fuseaction)>
			<cfif variables.fuseactionIsMethod>
				<cfset this.fuseactions[arguments.fuseaction] = 
							createObject("component","fuseboxControllerMethod")
								.init(this,variables.dottedPath,arguments.fuseaction,true) />
			<cfelse>
				<!--- attempt to find the fuseaction as a file in the circuit directory --->
				<cfif fileExists(variables.fullPath & arguments.fuseaction & ".xml")>
					<!--- fuseaction.xml fragment --->
					<cfthrow type="fusebox.undefinedFuseaction" 
							message="undefined Fuseaction" 
							detail="You specified a Fuseaction of #arguments.fuseaction# which is not defined in Circuit #getAlias()#." />
				<cfelseif fileExists(variables.fullPath & arguments.fuseaction & ".cfc")>
					<!--- fuseaction.cfc (call do() on this) --->
					<cfset variables.dottedPath = getApplication().locateCfc(variables.fullPath & arguments.fuseaction & ".cfc") />
					<cfif variables.dottedPath is not "">
						<cfset this.fuseactions[arguments.fuseaction] = 
									createObject("component","fuseboxControllerMethod")
										.init(this,variables.dottedPath,arguments.fuseaction,false) />
					<cfelse>
						<cfthrow type="fusebox.undefinedFuseaction" 
								message="undefined Fuseaction" 
								detail="You specified a Fuseaction of #arguments.fuseaction# which is not defined in Circuit #getAlias()#." />
					</cfif>
				<cfelseif fileExists(variables.fullPath & arguments.fuseaction & ".cfm")>
					<!--- fuseaction.cfm (i.e., a fuse) --->
					<cfset this.fuseactions[arguments.fuseaction] = 
								createObject("component","fuseboxImplicitFuseaction")
									.init(this,arguments.fuseaction) />
				<cfelse>
					<cfthrow type="fusebox.undefinedFuseaction" 
							message="undefined Fuseaction" 
							detail="You specified a Fuseaction of #arguments.fuseaction# which is not defined in Circuit #getAlias()#." />
				</cfif>
			</cfif>
		</cfif>

		<cfif arguments.topLevel>
			<cfif this.access is not "public">
				<cfthrow type="fusebox.invalidAccessModifier" 
						message="Invalid Access Modifier" 
						detail="You tried to access #getAlias()#.#arguments.fuseaction# which does not have access modifier of public. A Fuseaction which is to be accessed from anywhere outside the application (such as called via an URL, or a FORM, or as a web service) must have an access modifier of public or if unspecified at least inherit such a modifier from its circuit." />
			</cfif>
		</cfif>	

		<cfset this.fuseactions[arguments.fuseaction].compile(arguments.writer) />
		
		<!--- postfuseaction is handled internally to the circuit mechanism --->

		<cfset arguments.writer.setFuseaction(f) />
		
	</cffunction>

	<cffunction name="compilePreOrPostFuseaction" returntype="void" access="public" output="false" 
				hint="I compile the pre/post-fuseaction for a circuit.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />
		<cfargument name="preOrPost" type="string" required="false" 
					hint="I am either 'pre' or 'post' to indicate whether this is a prefuseaction or a postfuseaction. I am required but it's faster to specify that I am not required." />

		<!--- implicit circuits do not have pre/post fuseactions so this is a no-op --->

	</cffunction>
	
	<cffunction name="buildCircuitTrace" returntype="void" access="public" output="false" 
				hint="I build the 'circuit trace' structure - the array of parents. Required for Fusebox 4.1 compatibility.">

		<cfset this.circuitTrace = arrayNew(1) />
		<cfset arrayAppend(this.circuitTrace,getAlias()) />
		
	</cffunction>
	
	<cffunction name="getOriginalPath" returntype="string" access="public" output="false" 
				hint="I return the original relative path specified in the circuit declaration.">
		
		<cfreturn variables.originalPath />
		
	</cffunction>
	
	<cffunction name="getCircuitRoot" returntype="string" access="public" output="false" 
				hint="I return the full file system path to the circuit directory.">

		<cfreturn variables.fullPath />
		
	</cffunction>
	
	<cffunction name="getCircuitXMLFilename" returntype="string" access="public" output="false" 
				hint="I return the actual name of the circuit XML file: circuit.xml or circuit.xml.cfm.">
		
		<!--- there is no XML file for an implicit circuit --->
		<cfreturn "" />
		
	</cffunction>
	
	<cffunction name="getOriginalPathIsRelative" returntype="string" access="public" output="false" 
				hint="I return true if this circuit's declaration used a relative path.">
		
		<!--- original path is relative by definition --->
		<cfreturn true />
		
	</cffunction>
	
	<cffunction name="getParentName" returntype="string" access="public" output="false" 
				hint="I return the name (alias) of this circuit's parent.">
	
		<cfreturn this.parent />
	
	</cffunction>

	<cffunction name="hasParent" returntype="boolean" access="public" output="false" 
				hint="I return true if this circuit has a parent, otherwise I return false.">
	
		<cfreturn getParentName() is not "" />
	
	</cffunction>

	<cffunction name="getParent" returntype="any" access="public" output="false" 
				hint="I return this circuit's parent circuit object. I throw an exception if hasParent() returns false.">
	
		<!---
			note that this will throw an exception if the circuit has no parent
			code should call hasParent() first
		--->
		<cfreturn variables.fuseboxApplication.circuits[getParentName()] />
	
	</cffunction>

	<cffunction name="getPermissions" returntype="string" access="public" output="false" 
				hint="I return the aggregated permissions for this circuit.">
		<cfargument name="useCircuitTrace" type="boolean" default="false" 
					hint="I indicate whether or not to inherit the parent circuit's permissions if this circuit has no permissions specified." />

		<cfreturn this.permissions />
				
	</cffunction>

	<cffunction name="getRelativePath" returntype="string" access="public" output="false" 
				hint="I return the normalized relative path from the application root to this circuit's directory.">
	
		<cfreturn variables.relativePath />
	
	</cffunction>

	<cffunction name="getFuseactions" returntype="struct" access="public" output="false" 
				hint="I return the structure containing the definitions of the fuseactions within this circuit.">
		
		<cfreturn this.fuseactions /> 
		
	</cffunction>

	<cffunction name="getLexiconDefinition" returntype="any" access="public" output="false" 
				hint="I return the definition of the specified lexicon.">
		<cfargument name="namespace" type="any" required="false" 
					hint="I am the namespace whose lexicon is to be retrieved. I am required but it's faster to specify that I am not required." />
		
		<cfif arguments.namespace is variables.fuseboxLexicon.namespace>
			<cfreturn variables.fuseboxLexicon />
		<!--- else we return nothing because this is an illegal call --->
		</cfif>

	</cffunction>

	<cffunction name="getAccess" returntype="any" access="public" output="false" 
				hint="I return the access specified for this circuit.">
	
		<cfreturn this.access />
	
	</cffunction>
	
	<cffunction name="getAlias" returntype="any" access="public" output="false" 
				hint="I return the circuit alias.">
	
		<cfreturn variables.alias />
	
	</cffunction>

	<cffunction name="getApplication" returntype="any" access="public" output="false" 
				hint="I return the fusebox application object.">
	
		<cfreturn variables.fuseboxApplication />
	
	</cffunction>

	<cffunction name="getCustomAttributes" returntype="struct" access="public" output="false" 
				hint="I return any custom attributes for the specified namespace prefix.">
		<cfargument name="ns" type="string" required="true" 
					hint="I am the namespace for which to return custom attributes." />
		
		<!--- implicit circuits have no custom attributes --->
		<cfreturn structNew() />

	</cffunction>

</cfcomponent>