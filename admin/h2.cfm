<cfquery datasource="mysql" name="tbl">
SELECT * FROM information_schema.tables
WHERE table_name LIKE 'myho%'
</cfquery>
<!--- Drop tables --->
<cfloop query="tbl">
	<cfquery datasource="mysql">
	SET foreign_key_checks = 0;
	</cfquery>
	<cfquery datasource="mysql">
		DROP TABLE razuna.#table_name#
	</cfquery>
</cfloop>

<!--- <cfloop query="x">
	<cfdump var="#x#">
	<cfquery datasource="mysql">
		<cfif CONSTRAINT_NAME EQ "primary">
			ALTER TABLE #CONSTRAINT_SCHEMA#.#table_name# DROP PRIMARY KEY
		<cfelse>
			ALTER TABLE #CONSTRAINT_SCHEMA#.#table_name# DROP INDEX #CONSTRAINT_NAME#
		</cfif>
	</cfquery>
</cfloop> --->