

<cfset oMetadata = CreateObject("component","metadata")>
<!--- 
<cfset stDatasources = oMetaData.GetAllDatasources()>

<cfset driver = stDatasources["CMS01AdsTags"].driver>

<cfdump var="#driver#">

<cfset qTables = oMetaData.getTables("CMS01AdsTags")>

<cfdump var="#qTables#">

<cfset qFields = oMetaData.getFields("CMS01AdsTags","Site")>

<cfdump var="#qFields#">

<cfset qParentRelationships = oMetaData.getParentRelationships("CMS01AdsTags","Fuseaction")>

<cfdump var="#qParentRelationships#">

<cfset qChildRelationships = oMetaData.getChildRelationships("CMS01AdsTags","Site")>

<cfdump var="#qChildRelationships#">
 --->

<cfset xConfigFile = oMetaData.read("C:\InetPub\wwwroot\Scaffolder\scaffolding.xml")>


<cfset test = oMetaData.getTablesFromXML()>
<!--- <cfdump var="#test#"> --->

<cfset test = oMetaData.getFieldsFromXML("Fuseaction")>
<cfdump var="#test#" label="Fields">

<cfset test = oMetaData.getRelationshipsFromXML("Fuseaction","oneToMany")>
<cfdump var="#test#" label="oneToMany">

<cfset test = oMetaData.getRelationshipsFromXML("Fuseaction","manyToOne")>
<cfdump var="#test#" label="manyToOne">

<cfset test = oMetaData.getRelationshipsFromXML("Fuseaction","manyToMany")>
<cfdump var="#test#" label="manyToMany">