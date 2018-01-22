<cfabort>

<cfquery datasource="razuna_default">
update razuna_config
set conf_datasource = 'mysql', conf_database = 'mysql', conf_firsttime = false, conf_url_assets = 'http://127.0.0.1'
</cfquery>

<!--- Just a placeholder. Devs can do some stuff here. --->
<cfquery datasource="razuna_default" name="x">
select * from razuna_config
</cfquery>
<cfdump var="#x#">
