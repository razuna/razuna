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
			hint="I represent a fuseaction as a method within a controller CFC or a controller within an implicit circuit.">

	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="circuit" type="any" required="false" 
					hint="I am the circuit to which this fuseaction belongs. I am required but it's faster to specify that I am not required." />
		<cfargument name="dottedPath" type="string" required="false" 
					hint="I am the dotted path to the CFC. I am required but it's faster to specify that I am not required." />
		<cfargument name="name" type="any" required="false" 
					hint="I am the name of the fuseaction. I am required but it's faster to specify that I am not required." />
		<cfargument name="fuseactionIsMethod" type="any" required="false"
					hint="I indicate whether the fuseaction is method (or a controller). I am required but it's faster to specify that I am not required." />
		
		<cfset variables.circuit = arguments.circuit />
		<cfset variables.dottedPath = arguments.dottedPath />
		<cfset variables.name = arguments.name />
		<cfset variables.fuseactionIsMethod = arguments.fuseactionIsMethod />
		
		<!--- implicit circuit fuseactions are public by default --->
		<cfset this.access = "public" />
		<cfset this.permissions = "" />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="compile" returntype="void" access="public" output="false" 
				hint="I compile this fuseaction.">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the writer object to which the compiled code should be written. I am required but it's faster to specify that I am not required." />
	
		<cfset var uniqueName = "__fuseboxCircuitCfc_" & replace(replace(variables.dottedPath,"-","$","all"),".","_","all") />
		
		<cfset arguments.writer.println('<cfparam name="#uniqueName#" default="##createObject(''component'',''#variables.dottedPath#'')##" />') />

		<!---
			TODO: technically it is not correct to call prefuseaction() / postfuseaction() for a do() method since that 
			represents just a fuseaction in a circuit and really we should check for prefuseaction.cfm and prefuseaction.cfc (do)
			instead...
		--->
		<cfset arguments.writer.println('<cfif structKeyExists(#uniqueName#,"prefuseaction") and isCustomFunction(#uniqueName#.prefuseaction)>') />
		<cfset arguments.writer.println('<cfset #uniqueName#.prefuseaction(myFusebox=myFusebox,event=event) />') />
		<cfset arguments.writer.println('</cfif>') />
		
		<cfif variables.fuseactionIsMethod>
			<cfset arguments.writer.println('<cfif structKeyExists(#uniqueName#,"#getName()#") and isCustomFunction(#uniqueName#.#getName()#)>') />
			<cfset arguments.writer.println('<cfset #uniqueName#.#getName()#(myFusebox=myFusebox,event=event) />') />
			<cfset arguments.writer.println('<cfelse><' &
				'cfthrow type="fusebox.undefinedFuseaction" ' &
						'message="undefined Fuseaction" ' &
						'detail="You specified a Fuseaction of #getName()# which is not defined in Circuit #getCircuit().getAlias()#.">') />
			<cfset arguments.writer.println('</cfif>') />
		<cfelse>
			<cfset arguments.writer.println('<cfif structKeyExists(#uniqueName#,"do") and isCustomFunction(#uniqueName#.do)>') />
			<cfset arguments.writer.println('<cfset #uniqueName#.do(myFusebox=myFusebox,event=event) />') />
			<cfset arguments.writer.println('<cfelse><' &
				'cfthrow type="fusebox.undefinedFuseaction" ' &
						'message="undefined Fuseaction" ' &
						'detail="You specified a Fuseaction of #getName()# which is not defined in Circuit #getCircuit().getAlias()#.">') />
			<cfset arguments.writer.println('</cfif>') />
		</cfif>

		<cfset arguments.writer.println('<cfif structKeyExists(#uniqueName#,"postfuseaction") and isCustomFunction(#uniqueName#.postfuseaction)>') />
		<cfset arguments.writer.println('<cfset #uniqueName#.postfuseaction(myFusebox=myFusebox,event=event) />') />
		<cfset arguments.writer.println('</cfif>') />
		
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
