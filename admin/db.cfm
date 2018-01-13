<cfabort>
<!--- Just a placeholder. Devs can do some stuff here. --->
<cfquery datasource="razuna_default" name="x">
select * from razuna_config
</cfquery>
<cfdump var="#x#">
