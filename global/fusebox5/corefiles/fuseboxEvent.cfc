<cfcomponent output="false" hint="I am a simple object wrapper for attributes scope.">
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

	<cffunction name="init" returntype="any" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="attributes" type="struct" required="true" 
					hint="I am the attributes scope passed in." />
		<cfargument name="xfa" type="struct" required="true" 
					hint="I am the XFA scope passed in." />
		<cfargument name="myFusebox" type="any" required="true" 
					hint="I am the myFusebox object passed in." />
		
		<cfset variables.attributes = arguments.attributes />
		<cfset variables.xfa = arguments.xfa />
		<cfset variables.myFusebox = arguments.myFusebox />
		
		<cfreturn this />
	
	</cffunction>

	<cffunction name="getValue" returntype="any" access="public" output="false" 
				hint="I return a given attribute value, or the default if it is not present.">
		<cfargument name="valueName" type="string" required="true" 
					hint="I am the name of the attribute to return." />
		<cfargument name="defaultValue" type="any" default="" 
					hint="I am the default value to return if the given attribute is missing." />

		<cfif valueExists(arguments.valueName)>
			<cfreturn variables.attributes[arguments.valueName] />
		<cfelse>
			<cfreturn arguments.defaultValue />
		</cfif>

	</cffunction>

	<cffunction name="valueExists" returntype="boolean" access="public" output="false" 
				hint="I check with a given attribute value is present.">
		<cfargument name="valueName" type="string" required="true" 
					hint="I am the name of the attribute to check." />

		<cfreturn structKeyExists(variables.attributes,arguments.valueName) />

	</cffunction>

	<cffunction name="setValue" returntype="void" access="public" output="false" 
				hint="I update the given attribute value.">
		<cfargument name="valueName" type="string" required="true" 
					hint="I am the name of the attribute to update." />
		<cfargument name="newValue" type="any" required="true" 
					hint="I am the new value for the given attribute." />
		
		<cfset variables.attributes[arguments.valueName] = arguments.newValue />

	</cffunction>

	<cffunction name="getAllValues" returntype="any" access="public" output="false" 
				hint="I return a struct containing all the attribute values - this is a reference to the actual attributes scope.">
		
		<cfreturn variables.attributes />

	</cffunction>

	<cffunction name="removeValue" returntype="void" access="public" output="false" 
				hint="I remove a given attribute's value.">
		<cfargument name="valueName" type="string" required="true" 
					hint="I am the name of the attribute to remove." />

		<cfset structDelete(variables.attributes,arguments.valueName) />

	</cffunction>
	
	<cffunction name="xfa" returntype="string" access="public" output="false" 
				hint="I set/get an eXit FuseAction.">
		<cfargument name="name" type="string" required="true" 
					hint="I am the XFA to get/set." />
		<cfargument name="value" type="string" required="false" 
					hint="I am the optional value to set." />
		
		<cfset var xfaValue = "" />
		<cfset var n = arrayLen(arguments) />
		<cfset var i = 3 />
		
		<cfif structKeyExists(arguments,"value")>
			<cfif listLen(arguments.value,".") gte 2>
				<cfset variables.xfa[arguments.name] = arguments.value />
			<cfelse>
				<cfset variables.xfa[arguments.name] = variables.myFusebox.thisCircuit & "." & arguments.value />
			</cfif>
			<cfif n mod 2 neq 0>
				<cfthrow type="fusebox.badGrammar,illegalArguments" 
						message="Odd arguments to event.xfa()" 
						detail="event.xfa() must be passed an even number of arguments as name-value pairs." />
			</cfif>
			<cfloop condition="i lt n">
				<cfset variables.xfa[arguments.name] = variables.xfa[arguments.name] &
						variables.myFusebox.getApplication().queryStringSeparator & arguments[i] &
								variables.myFusebox.getApplication().queryStringEqual & arguments[i+1] />
				<cfset i = i + 2 />
			</cfloop>
		</cfif>
		
		<cfif structKeyExists(variables.xfa,arguments.name)>
			<cfset xfaValue = variables.xfa[arguments.name] />
		</cfif>
		
		<cfreturn xfaValue />
		
	</cffunction>

</cfcomponent>
