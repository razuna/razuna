<cfoutput>
	<div>This is a traditional skeleton Fusebox 5.5 application.</div>
	<hr />
	#body#
	<hr />
	<div align="right">Powered by Fusebox 5.5!
		(build <cfoutput>#myFusebox.getApplication().getVersion()# - #myFusebox.getApplication().mode#</cfoutput>)</div>
</cfoutput>
