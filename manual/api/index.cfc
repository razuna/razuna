<cfcomponent output="false">

	<cffunction name="details" access="remote" returnformat="plain">
		<cfargument name="type" default="tag" 		required="true" 		hint="Pass in either tag or function" />
		<cfargument name="tag"  default="cfquery" required="true" 		hint="The tag/function you want info on" />

		<cfset var tag 	= Lcase( arguments.tag ) />
		<cfset var info = {} />

		<cfif ( arguments.type == "tag" ) >

			<cftry>
				<cfset info = GetEngineTagInfo( tag ) />
				
				<cfcatch>
					<cfset info.error = "No Such Tag Exists" />
				</cfcatch>
			</cftry>

		<cfelse>

			<cftry>
				<cfset info = GetEngineFunctionInfo( tag )>

				<cfcatch>
					<cfset info.error = "No Such Function Exists" />
				</cfcatch>
			</cftry>

		</cfif>

		<cfreturn info />

	</cffunction>

</cfcomponent>