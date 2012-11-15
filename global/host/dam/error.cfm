<cfif cgi.http_host CONTAINS "razunabd.local">
<cfdump var="#error#">
<cfelse>
<!--- Outpout to user --->
<h2 style="color:red;">We are so sorry. Something went wrong. <cfif application.razuna.isp OR cgi.http_host CONTAINS "razunabd.local">We have been notified of this error and will fix it asap.<cfelse>We saved the error and you or your administrator can notify us of this error within the Administration.</cfif></h2>
<!--- Save content --->
<cfsavecontent variable="errortext">
<cfoutput>
An error occurred: http://#cgi.server_name##cgi.script_name#?#cgi.query_string#<br />
Time: #dateFormat(now(), "short")# #timeFormat(now(), "short")#<br />

<cfdump var="#error#" label="Error">
<cfdump var="#session#" label="Session">
<cfdump var="#form#" label="Form">
<cfdump var="#url#" label="URL">

</cfoutput>
</cfsavecontent>
<!--- Increment ID --->
<cfquery datasource="#application.razuna.datasource#" name="qryid">
SELECT <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(max(id),0) + 1 as theid
FROM #session.hostdbprefix#errors
</cfquery>
<!--- Add to DB --->
<cfquery datasource="#application.razuna.datasource#">
INSERT INTO #session.hostdbprefix#errors
(id, err_text, err_date, host_id)
VALUES(
<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#qryid.theid#">,
<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#errortext#">,
<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#session.hostid#">
)
</cfquery>
<!--- Flush Cache --->
<cfinvoke component="extQueryCaching" method="resetcachetoken" type="logs" />
<!--- eMail --->
<cfif cgi.http_host CONTAINS "razuna.com" OR cgi.http_host CONTAINS "razunabd.local">
<cfmail to="bugs@razuna.com" from="server@razuna.com" subject="Razuna Error: #cgi.server_name# - #error.message#" type="html">
#errortext#
</cfmail>
</cfif>
</cfif>