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
			hint="I represent a fuseaction within a circuit.">

	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="circuit" type="any" required="false" 
					hint="I am the circuit to which this fuseaction belongs. I am required but it's faster to specify that I am not required." />
		<cfargument name="name" type="any" required="false" 
					hint="I am the name of the fuseaction. I am required but it's faster to specify that I am not required." />
		<cfargument name="access" type="any" required="false" 
					hint="I am the access criteria for the fuseaction. I am required but it's faster to specify that I am not required." />
		<cfargument name="children" type="any" required="false" 
					hint="I am the verbs for this fuseaction. I am required but it's faster to specify that I am not required." />
		<cfargument name="global" type="any" default="false" 
					hint="I indicate whether or not this is a globalfuseaction in fusebox.xml." />
		<cfargument name="customAttribs" type="any" default="#structNew()#" 
					hint="I hold the custom (namespace-qualified) attributes in the fuseaction tag." />
		
		<cfset var i = 0 />
		<cfset var verb = "" />
		<cfset var factory = arguments.circuit.getApplication().getFuseactionFactory() />

		<cfset variables.circuit = arguments.circuit />
		<cfset variables.name = arguments.name />
		<cfset variables.customAttributes = arguments.customAttribs />
		<cfset variables.nChildren = arrayLen(arguments.children) />
		<cfset variables.actions = structNew() />
		
		<cfset this.access = arguments.access />
		
		<cfloop from="1" to="#variables.nChildren#" index="i">
			<cfset variables.actions[i] = factory.create(arguments.children[i].xmlName,
					this,arguments.children[i].xmlAttributes,arguments.children[i].xmlChildren,
						arguments.global) />
		</cfloop>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="compile" returntype="void" access="public" output="false" 
				hint="I compile this fuseaction.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the writer object to which the compiled code should be written. I am required but it's faster to specify that I am not required." />
	
		<cfset var i = 0 />
		<cfset var n = 0 />
		
		<cfloop from="1" to="#variables.nChildren#" index="i">
			<cfset variables.actions[i].compile(arguments.writer) />
		</cfloop>
		
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
		<cfargument name="inheritFromCircuit" type="boolean" default="true" 
					hint="I indicate whether or not the circuit's permissions should be returned if this fuseaction has no permissions specified." />
		<cfargument name="useCircuitTrace" type="boolean" default="false" 
					hint="I indicate whether or not to inherit the parent circuit's permissions if this fuseaction's circuit has no permissions specified." />
	
		<cfif this.permissions is "" and arguments.inheritFromCircuit>
			<cfreturn getCircuit().getPermissions(arguments.useCircuitTrace) />
		<cfelse>
			<cfreturn this.permissions />
		</cfif>
	
	</cffunction>
	
	<cffunction name="getCustomAttributes" returntype="struct" access="public" output="false" 
				hint="I return the custom (namespace-qualified) attributes for this fuseaction tag.">
		<cfargument name="ns" type="string" required="true" 
					hint="I am the namespace prefix whose attributes should be returned." />
		
		<cfif structKeyExists(variables.customAttributes,arguments.ns)>
			<!--- we structCopy() this so folks can't poke values back into the metadata! --->
			<cfreturn structCopy(variables.customAttributes[arguments.ns]) />
		<cfelse>
			<cfreturn structNew() />
		</cfif>
		
	</cffunction>
	
</cfcomponent>
