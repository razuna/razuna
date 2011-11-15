<cfsilent>
	<!---
		sample Application.cfm for ColdFusion MX 6.1 and other compatible systems that do not support Application.cfc
		
		trapping non-index.cfm requests is not necessary with Application.cfc if you extend fusebox5.Application:
	--->
	<cfif right(cgi.script_name, len("index.cfm")) neq "index.cfm" and right(cgi.script_name, 3) neq "cfc">
		<cflocation url="index.cfm" addtoken="no" />
	</cfif>
	<!--- there must be no newline after the closing cfsilent tag if you want all leading whitespace suppressed --->
</cfsilent>