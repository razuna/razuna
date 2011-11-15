<!--- (see below for usage information)
Copyright 2007 TeraTech, Inc. http://teratech.com/

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

	assertions plugin for Fusebox 5.x
	
	usage:
		1. declare the plugin as part of the prefuseaction and postfuseaction
		   phases in your fusebox.xml and name both declarations "assert":

			<plugins>
				<phase name="preFuseaction">
					<plugin name="assert" template="assertions" />
				</phase>
				<phase name="postFuseaction">
					<plugin name="assert" template="assertions" />
				</phase>
			</plugins>

		2. declare the assert prefix in your circuit.xml files:

			<circuit xmlns:assert="assertions">
		
		3. declare preconditions, postconditions and invariants on your
		   fuseactions:

			<fuseaction name="welcome"
				assert:precondition="1 eq 1"
				assert:postcondition="0 eq 0"
				assert:invariant="new{myFusebox.thisFuseaction} eq old{myFusebox.thisFuseaction}">
				...
			</fuseaction>
		
	invariants:
		old{variableName} lets an invariant refer to the value of a variable
			as it was set at the beginning of the fuseaction
		new{variableName} is just a synonym for variableName for symmetry

--->
<cfparam name="myFusebox.plugins[myFusebox.thisPlugin].invariants" default="#structNew()#" />
<cfparam name="myFusebox.plugins[myFusebox.thisPlugin].invariants.#myFusebox.thisCircuit#$#myFusebox.thisFuseaction#" default="#structNew()#" />
<cfset myFusebox.plugins[myFusebox.thisPlugin].customAttrs = 
		myFusebox.getApplication()
			.circuits[myFusebox.thisCircuit]
				.fuseactions[myFusebox.thisFuseaction]
					.getCustomAttributes(myFusebox.thisPlugin) />
<cfif myFusebox.thisPhase is "prefuseaction">
	<!--- check the precondition is true --->
	<cfif structKeyExists(myFusebox.plugins[myFusebox.thisPlugin].customAttrs,"precondition")>
		<cfif not evaluate(myFusebox.plugins[myFusebox.thisPlugin].customAttrs.precondition)>
			<cfthrow type="fusebox.failedAssertion.precondition"
					message="Assert precondition failed" 
					detail="The precondition {#myFusebox.plugins[myFusebox.thisPlugin].customAttrs.precondition#} was false for Fuseaction #myFusebox.thisFuseaction# in Circuit #myFusebox.thisCircuit#" />
		</cfif>
	</cfif>
	<!--- parse the invariant and remember any old{variable} data --->
	<cfif structKeyExists(myFusebox.plugins[myFusebox.thisPlugin].customAttrs,"invariant")>
		<!--- search for old{var} and save all those values --->
		<cfset myFusebox.plugins[myFusebox.thisPlugin].start = 1 />
		<cfset myFusebox.plugins[myFusebox.thisPlugin].match = REFind("old{([^}]*)}",myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant,myFusebox.plugins[myFusebox.thisPlugin].start,true) />
		<cfloop condition="myFusebox.plugins[myFusebox.thisPlugin].match.pos[1] neq 0">
			<cfset myFusebox.plugins[myFusebox.thisPlugin].old = mid(myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant,myFusebox.plugins[myFusebox.thisPlugin].match.pos[2],myFusebox.plugins[myFusebox.thisPlugin].match.len[2]) />
			<cfset myFusebox.plugins[myFusebox.thisPlugin].invariants["#myFusebox.thisCircuit#$#myFusebox.thisFuseaction#"][myFusebox.plugins[myFusebox.thisPlugin].old] = evaluate(myFusebox.plugins[myFusebox.thisPlugin].old) />
			<cfset myFusebox.plugins[myFusebox.thisPlugin].start = myFusebox.plugins[myFusebox.thisPlugin].match.pos[1] + myFusebox.plugins[myFusebox.thisPlugin].match.len[1] />
			<cfset myFusebox.plugins[myFusebox.thisPlugin].match = REFind("old{([^}]*)}",myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant,myFusebox.plugins[myFusebox.thisPlugin].start,true) />
		</cfloop>
	</cfif>
<cfelseif myFusebox.thisPhase is "postfuseaction">
	<!--- check the postcondition is true --->
	<cfif structKeyExists(myFusebox.plugins[myFusebox.thisPlugin].customAttrs,"postcondition")>
		<cfif not evaluate(myFusebox.plugins[myFusebox.thisPlugin].customAttrs.postcondition)>
			<cfthrow type="fusebox.failedAssertion.postcondition"
					message="Assert postcondition failed" 
					detail="The postcondition {#myFusebox.plugins[myFusebox.thisPlugin].customAttrs.postcondition#} was false for Fuseaction #myFusebox.thisFuseaction# in Circuit #myFusebox.thisCircuit#" />
		</cfif>
	</cfif>
	<!--- parse the invariant and substitute any old{} / new{} values --->
	<cfif structKeyExists(myFusebox.plugins[myFusebox.thisPlugin].customAttrs,"invariant")>
		<!--- search for old{var} and substitute those values --->
		<cfset myFusebox.plugins[myFusebox.thisPlugin].evalInvariant = myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant />
		<cfset myFusebox.plugins[myFusebox.thisPlugin].start = 1 />
		<cfset myFusebox.plugins[myFusebox.thisPlugin].match = REFind("old{([^}]*)}",myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant,myFusebox.plugins[myFusebox.thisPlugin].start,true) />
		<cfloop condition="myFusebox.plugins[myFusebox.thisPlugin].match.pos[1] neq 0">
			<cfset myFusebox.plugins[myFusebox.thisPlugin].old = mid(myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant,myFusebox.plugins[myFusebox.thisPlugin].match.pos[2],myFusebox.plugins[myFusebox.thisPlugin].match.len[2]) />
			<cfset myFusebox.plugins[myFusebox.thisPlugin].evalInvariant = replace(myFusebox.plugins[myFusebox.thisPlugin].evalInvariant,"old{#myFusebox.plugins[myFusebox.thisPlugin].old#}","myFusebox.plugins[myFusebox.thisPlugin].invariants.#myFusebox.thisCircuit#$#myFusebox.thisFuseaction#[""#myFusebox.plugins[myFusebox.thisPlugin].old#""]","one") />
			<cfset myFusebox.plugins[myFusebox.thisPlugin].start = myFusebox.plugins[myFusebox.thisPlugin].match.pos[1] + myFusebox.plugins[myFusebox.thisPlugin].match.len[1] />
			<cfset myFusebox.plugins[myFusebox.thisPlugin].match = REFind("old{([^}]*)}",myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant,myFusebox.plugins[myFusebox.thisPlugin].start,true) />
		</cfloop>
		<!--- search for new{var} and substitute those values --->
		<cfset myFusebox.plugins[myFusebox.thisPlugin].start = 1 />
		<cfset myFusebox.plugins[myFusebox.thisPlugin].match = REFind("new{([^}]*)}",myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant,myFusebox.plugins[myFusebox.thisPlugin].start,true) />
		<cfloop condition="myFusebox.plugins[myFusebox.thisPlugin].match.pos[1] neq 0">
			<cfset myFusebox.plugins[myFusebox.thisPlugin].new = mid(myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant,myFusebox.plugins[myFusebox.thisPlugin].match.pos[2],myFusebox.plugins[myFusebox.thisPlugin].match.len[2]) />
			<cfset myFusebox.plugins[myFusebox.thisPlugin].evalInvariant = replace(myFusebox.plugins[myFusebox.thisPlugin].evalInvariant,"new{#myFusebox.plugins[myFusebox.thisPlugin].new#}","#myFusebox.plugins[myFusebox.thisPlugin].new#","one") />
			<cfset myFusebox.plugins[myFusebox.thisPlugin].start = myFusebox.plugins[myFusebox.thisPlugin].match.pos[1] + myFusebox.plugins[myFusebox.thisPlugin].match.len[1] />
			<cfset myFusebox.plugins[myFusebox.thisPlugin].match = REFind("new{([^}]*)}",myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant,myFusebox.plugins[myFusebox.thisPlugin].start,true) />
		</cfloop>
		<cfif not evaluate(myFusebox.plugins[myFusebox.thisPlugin].evalInvariant)>
			<cfthrow type="fusebox.failedAssertion.invariant"
					message="Assert invariant failed" 
					detail="The invariant {#myFusebox.plugins[myFusebox.thisPlugin].customAttrs.invariant#} was false for Fuseaction #myFusebox.thisFuseaction# in Circuit #myFusebox.thisCircuit#" />
		</cfif>
	</cfif>
<cfelse>
	<!--- no idea why the assertion plugin was invoked: ignore it --->
</cfif>
