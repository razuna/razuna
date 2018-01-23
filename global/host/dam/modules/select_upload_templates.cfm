<cfoutput>
	<select name="template_#attributes.type#" style="float:right;">
		<option value="0">Select template</option>
		<option value="0">----</option>
		<cfloop query="attributes.qry_templates">
			<option value="#upl_temp_id#">#upl_name#</option>
		</cfloop>
	</select>
</cfoutput>