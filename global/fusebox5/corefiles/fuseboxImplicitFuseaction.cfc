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
			hint="I represent a fuseaction as a file within an implicit circuit.">

	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="circuit" type="any" required="false" 
					hint="I am the circuit to which this fuseaction belongs. I am required but it's faster to specify that I am not required." />
		<cfargument name="name" type="any" required="false" 
					hint="I am the name of the fuseaction. I am required but it's faster to specify that I am not required." />
		
		<cfset variables.circuit = arguments.circuit />
		<cfset variables.name = arguments.name />
		
		<!--- implicit circuit fuseactions are public by default --->
		<cfset this.access = "public" />
		<cfset this.permissions = "" />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="compile" returntype="void" access="public" output="false" 
				hint="I compile this fuseaction.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the writer object to which the compiled code should be written. I am required but it's faster to specify that I am not required." />
	
		<cfset var circuitPath = getCircuit().getApplication().parseRootPath & getCircuit().getRelativePath() />
		<cfset var rootCircuitPath = getCircuit().getApplication().appRootDirectory & getCircuit().getApplication().parsePath & circuitPath />
		
		<!--- implicit prefuseaction --->
		<cfset arguments.writer.println('<' &
			'cfif fileExists("#rootCircuitPath#prefuseaction.cfm")><' &
			'cfoutput><cfinclude ' &
			'template="#circuitPath#prefuseaction.cfm" /><' &
			'/cfoutput><' &
			'/cfif>') />
		<!--- main fuseaction --->
		<cfset arguments.writer.println('<' &
			'cfif fileExists("#rootCircuitPath##getName()#.cfm")><' &
			'cfoutput><cfinclude ' &
			'template="#circuitPath##getName()#.cfm" /><' &
			'/cfoutput><' &
			'cfelse><' &
			'cfthrow type="fusebox.undefinedFuseaction" ' &
					'message="undefined Fuseaction" ' &
					'detail="You specified a Fuseaction of #getName()# which is not defined in Circuit #getCircuit().getAlias()#."><' &
			'/cfif>') />
		<!--- implicit postfuseaction --->
		<cfset arguments.writer.println('<' &
			'cfif fileExists("#rootCircuitPath#postfuseaction.cfm")><' &
			'cfoutput><cfinclude ' &
			'template="#circuitPath#postfuseaction.cfm" /><' &
			'/cfoutput><' &
			'/cfif>') />

	</cffunction>
	
	<cffunction name="getName" returntype="string" access="public" output="false" 
				hint="I return the name of the fuseaction.">
		
		<cfreturn variables.name />
		
	</cffunction>

	<cffunction name="getCircuit" returntype="any" access="public" output="false" 
				hint="I return the enclosing circuit object.">
	
		<cfreturn variables.circuit />
	
	</cffunction>
	
	<cffunction name="getAccess" returntype="string" access="public" output="false" 
				hint="I am a convenience method to return this fuseaction's access attribute value.">
	
		<cfreturn this.access />
	
	</cffunction>
	
	<cffunction name="getPermissions" returntype="string" access="public" output="false" 
				hint="I return the aggregated permissions for this fuseaction.">
	
		<cfreturn this.permissions />
		
	</cffunction>
	
	<cffunction name="getCustomAttributes" returntype="struct" access="public" output="false" 
				hint="I return the custom (namespace-qualified) attributes for this fuseaction tag.">
		<cfargument name="ns" type="string" required="true" 
					hint="I am the namespace prefix whose attributes should be returned." />
		
		<cfreturn structNew() />

	</cffunction>

</cfcomponent>
