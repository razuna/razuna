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
<cfcomponent output="false" hint="I represent a class declaration in the fusebox XML file.">

	<cffunction name="init" returntype="fuseboxClassDefinition" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="type" type="string" required="false" 
					hint="I am 'component' or 'java', the type of the declared class." />
		<cfargument name="classpath" type="string" required="false" 
					hint="I am the package-qualified name of the declared class, e.g., java.lang.String or org.corfield.Sean" />
		<cfargument name="constructor" type="string" required="false" 
					hint="I am the name of the method that should be used to construct the declared class." />
		<cfargument name="customAttribs" type="struct" required="false" 
					hint="I am the set of custom attributes specified in the class declaration." />
	
		<!--- FB41 compatibility means these must be public data --->
		<cfset this.type = arguments.type />
		<cfset this.classpath = arguments.classpath />
		<cfset this.constructor = arguments.constructor />
		<cfset variables.customAttributes = arguments.customAttribs />
		
		<cfreturn this />
		
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
