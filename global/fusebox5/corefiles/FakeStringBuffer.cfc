<cfcomponent output="false" hint="I simulate java.lang.StringBuffer when that is disabled by the host.">
	
	<!--- hack to avoid clashing with built-in toString method --->
	<cfset variables.toString = $toString />
	
	<cffunction name="init" returntype="any" access="public" output="false">
		
		<cfset variables.buffer = "" />
		
		<cfreturn this />
			
	</cffunction>
	
	<cffunction name="append" returntype="any" access="public" output="false" 
				hint="I append a new string to the current buffer.">
		<cfargument name="newString" type="string" required="true" 
					hint="I am the new segment to append." />
					
		<cfset variables.buffer = variables.buffer & arguments.newString />
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="$toString" returntype="string" access="public" output="false" 
				hint="I return the current buffer as a string.">
		
		<cfreturn variables.buffer />
		
	</cffunction>

</cfcomponent>