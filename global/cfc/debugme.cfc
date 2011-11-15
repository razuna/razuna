<cfcomponent>
	
	<!--- Invoke with --->
	<!--- 
	<cfinvoke component="debugme" method="cfthread_join_dump" 
	emailto="support@razuna.com" 
	emailfrom="server@razuna.com" 
	emailsubject="debug" 
	threadname="trwritexmp89">
	 --->
	<cffunction name="cfthread_join_dump">
		<cfargument name="emailto" type="string">
		<cfargument name="emailfrom" type="string">
		<cfargument name="emailsubject" type="string">
		<cfargument name="threadname" type="string">
		<!--- Param for dump --->
		<cfset dumpname = "cfthread." & arguments.threadname>
		<!--- Join thread --->
		<cfthread name="#arguments.threadname#" action="join" />
		<!--- Send email --->
		<cfmail type="html" to="#arguments.emailto#" from="#arguments.emailfrom#" subject="#arguments.emailsubject#">
			<cfdump var="#evaluate(dumpname)#" />
		</cfmail>
	</cffunction>
	
	<!--- Invoke with --->
	<!--- 
	<cfinvoke component="debugme" method="email_dump" 
	emailto="support@razuna.com" 
	emailfrom="server@razuna.com" 
	emailsubject="debug" 
	dump="">
	 --->
	<cffunction name="email_dump">
		<cfargument name="emailto" type="string">
		<cfargument name="emailfrom" type="string">
		<cfargument name="emailsubject" type="string">
		<cfargument name="dump" type="Any">
		<!--- Send email --->
		<cfmail type="html" to="#arguments.emailto#" from="#arguments.emailfrom#" subject="#arguments.emailsubject#">
			<cfdump var="#arguments.dump#" />
		</cfmail>
	</cffunction>
	
	<cffunction name="email_message">
		<cfargument name="emailto" type="string">
		<cfargument name="emailfrom" type="string">
		<cfargument name="emailsubject" type="string">
		<cfargument name="message" type="Any">
		<!--- Send email --->
		<cfmail type="html" to="#arguments.emailto#" from="#arguments.emailfrom#" subject="#arguments.emailsubject#">
			#arguments.message#
		</cfmail>
	</cffunction>

	<!--- Write error into directory --->
	<cffunction name="write_error">
		<cfargument name="thestruct" type="struct">
		<!--- Set name of file --->
		<cfset err_file = dateformat(now(), "mm-dd-yyyy") & "_" & timeformat(now(), "hh-mm-ss-l") & ".html">
		<!--- Savecontent --->
		<cfsavecontent variable="therr"><cfdump var="#arguments.thestruct.cfcatch#" label="the error"><cfdump var="#arguments.thestruct#" label="the struct"></cfsavecontent>
		<!--- For local --->
		<cfif application.razuna.storage EQ "local">
			<!--- Check if errors folder exists, else create it --->
			<cfif not DirectoryExists("#arguments.thestruct.assetpath#/#session.hostid#/errors")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/errors" mode="775">
			</cfif>
			<!--- Write the error file --->
			<cffile action="write" file="#arguments.thestruct.assetpath#/#session.hostid#/errors/#err_file#" output="#therr#" mode="775">
		<!--- For Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix">
			<!--- Write the file to temp dir --->
			
			<!--- Upload file --->
			
			<!--- Set the uploaded file to public read --->
		</cfif>
		
		<cfreturn />
	</cffunction>

</cfcomponent>