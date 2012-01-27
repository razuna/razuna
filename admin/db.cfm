<cfquery datasource="razuna_default">
ALTER table razuna_config add conf_aws_location varchar(100)
</cfquery>
<cfabort>
<cfoutput>


<cfquery datasource="mysql" name="x">
SELECT
ke.referenced_table_name parent,
ke.table_name child,
ke.constraint_name
FROM
information_schema.KEY_COLUMN_USAGE ke
WHERE
(
ke.referenced_table_name LIKE '%'
AND ke.referenced_table_name IS NOT NULL
)
ORDER BY
ke.referenced_table_name
</cfquery>

<cfdump var="#x#">

<cfloop query="x">
	<cfquery datasource="mysql">
	SET foreign_key_checks = 0
	</cfquery>
	<cfquery datasource="mysql">
	DROP TABLE #child#
	</cfquery>
</cfloop>



</cfoutput>