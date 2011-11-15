<cfcomponent displayname="scaffolder.cfc" hint="I introspect the DBMS and write/update the metadata XML. I read the metadata XML to provide the data to the code generator.">
<!---
Copyright 2006-07 Objective Internet Ltd - http://www.objectiveinternet.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->
	<cfproperty name="project" type="string" hint="The selected project name." />
	<cfproperty name="template" type="string" hint="The selected template." />
	<cfproperty name="datasource" type="string" hint="The selected datasource name." />
	<cfproperty name="username" type="string" hint="Username to be used to access the datasource." />
	<cfproperty name="password" type="string" hint="Password to be used to access the datasource." />
	<cfproperty name="author" type="string" hint="I am the name of the author." />
	<cfproperty name="authorEmail" type="string" hint="I am the email of the author." />
	<cfproperty name="copyright" type="string" hint="I am the copyright statement." />
	<cfproperty name="licence" type="string" hint="I am the licence details." />
	<cfproperty name="version" type="string" hint="I am the version number." />
		
	<cfproperty name="DbType" type="string" hint="Type of DBMS for the selected datasource." />
	<cfproperty name="DbName" type="string" hint="Database name for the selected datasource." />
	<cfproperty name="DbBuffer" type="string" hint="Size of Driver Buffer." />
	<cfproperty name="aErrorMessages" type="array" hint="An array of error messages." />
	<cfproperty name="xScaffoldingConfig" type="any" hint="An xml document object containing the current configuration." />
	<cfproperty name="configFilePath" type="string" hint="The path to the configuration file." />
	<cfproperty name="selectedTable" type="string" hint="The currently selected table." />
	<cfproperty name="OS" type="string" hint="The currently selected table." />
	
	<cffunction name="init" returntype="metadata" output="No" 
				hint="I initialise the metadata object. If the scaffolding file exists I load it." >
		<cfargument name="configFilePath" required="No" type="string" default="#GetDirectoryFromPath(GetBaseTemplatePath())#scaffolding.xml" hint="I am a path to a scaffolding configuration file name." />
		<cfargument name="datasource" required="No" type="string" hint="I am a datasource name." />
		<cfargument name="username" required="No" type="string" hint="I am the username." default="" />
		<cfargument name="password" required="No" type="string" hint="I am the password." default="" />
		<cfargument name="project" required="No" type="string" hint="I am the project name." />
		<cfargument name="template" required="No" type="string" hint="I am the template type." />
		
		<cfargument name="author" required="No" type="string" hint="I am the name of the author." />
		<cfargument name="authorEmail" required="No" type="string" hint="I am the email of the author." />
		<cfargument name="copyright" required="No" type="string" hint="I am the copyright statement." />
		<cfargument name="licence" required="No" type="string" hint="I am the licence details." />
		<cfargument name="version" required="No" type="string" hint="I am the version number." />
		
		<cfset var stDatasources = GetAllDatasources()>
		<cfset var stDBMSLookup = getSupportedDBMS()>
		<cfset var lFields = "">
		<cfset var thisField = "">
		
		<cfset variables.aErrorMessages = ArrayNew(1)>
		<cfset variables.xScaffoldingConfig = "">
		<cfset variables.configFilePath = arguments.configFilePath>
		<cfset variables.selectedTable = "">
		<cfset variables.OSdelimiter = "#rereplace(gettemplatepath(), "[^\\/]*([\\/]).*", "\1")#">
		
		<!--- Get the config information from the scaffolding.xml file if it exists --->
		<cfset read(configFilePath=arguments.configFilePath)>
		
		<cfif isDefined("arguments.datasource")>
			<cfset variables.datasource=arguments.datasource>
			<cfset variables.username=arguments.username>
			<cfset variables.password=arguments.password>
			<cfif NOT isDefined("arguments.project")>
				<cfset variables.project=arguments.datasource>
			</cfif>
		</cfif>
		
		<cfif NOT isDefined("variables.datasource")>
			<cfthrow type="Application" message="Datasource not defined."
					 detail="There was no datasource name found in either the #configFilePath# file or the call to the scaffolding init. Please add one and try again.">
		</cfif>
		
		<cftry>
			<cfset variables.DbType = trim(stDBMSLookup[stDatasources[variables.datasource].driver])>
			<cfset variables.DbName = trim(stDatasources[variables.datasource].urlmap.database)>
			<cfset variables.DbBuffer = trim(stDatasources[variables.datasource].buffer)>
			<cfcatch>
				<cfthrow type="Application" message="Datasource not found or invalid." 
						 detail="The datasource name, #variables.datasource#, was not found or the DBMS is not of a supported type.">
			</cfcatch> 
		</cftry>
		
		<cfset lFields = "project,template,author,authorEmail,copyright,licence,version">
		<cfloop list="#lFields#" index="thisField">
			<cfif isDefined("arguments.#thisField#")>
				<cfset "variables.#thisField#" = arguments[thisField]>
			</cfif>
		</cfloop>
		
		<cfif NOT isDefined("variables.version") OR variables.version IS "">
			<cfset variables.version = "1.0">
		</cfif>
		
		<cfif NOT isDefined("variables.licence") OR variables.licence IS "">
			<cfset variables.licence = "See licence.txt">
		</cfif>
		
		<cfif NOT isDefined("variables.project") OR variables.project IS "">
			<cfset variables.project = variables.datasource>
		</cfif>
		
		<cfparam name="variables.author" default="">
		<cfparam name="variables.authorEmail" default="">
		<cfparam name="variables.copyright" default="">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="introspectDB" returntype="metadata" output="Yes" 
				hint="I introspect the database and update the XML configuration file." >
		<cfargument name="lTables" required="No" type="string" hint="I am a list of tables to generate scaffolding for. Default is to generate code for all tables in the database." />
		
		<cfset var qTables = getTables()>
		<cfset var lValidTables = "">
		<cfset var thisTable = "">
		<cfset var qFields = 0>
		<cfoutput>Introspecting database for datasource #variables.datasource#.<br /></cfoutput>
		<!--- Set up a list of valid tables to be used to generate code --->
		<cfif isDefined("arguments.lTables")>
			<cfloop query="qTables">
				<cfif ListFindNoCase(lTables,qTables.tablename)>
					<cfset lValidTables = ListAppend(lValidTables,qTables.tablename)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset lValidTables = ValueList(qTables.tablename)>
		</cfif>
		
		<!--- Create object tags for each table --->
		<cfset createObjectTags(lValidTables)>
		
		<!--- Loop over the tables and update the metadata XML for each one to match the database --->
		<!--- Do the basic properties first --->
		<cfloop list="#lValidTables#" index="thisTable">
			<cfset qFields = getFields(thisTable)>
			<cfset updateBaseFieldPropertiesFromQuery(thisTable,qFields)>
		</cfloop>
		<!--- Then add links to parent tables and finalise the display formats --->
		<cfloop list="#lValidTables#" index="thisTable">
			<cfset qParents = getParentRelationships(thisTable)>
			<cfset updateAllParentRelationshipsFromQuery(thisTable,qParents)>
			<cfset qFields = getFields(thisTable)>
			<cfset updateAdditionalFieldPropertiesFromQuery(thisTable,qFields)>
		</cfloop>
		
		<!--- Save the updated metadata --->
		<cfset save()>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="build" returntype="void" output="Yes" 
				hint="I build the code using the provided templates.">
		<cfargument name="cftemplate" type="any" required="Yes" 
					hint="I am the cftemplate that will be used to generate the code."/>
		<cfargument name="template" type="string" required="No" default="#variables.template#"
					hint="I am the subdirectory of templates to be used" /> 
		<cfargument name="destinationFilePath" type="string" required="No" default="#GetDirectoryFromPath(GetBaseTemplatePath())#" 
					hint="I am the path to the root of the application where the generated code will be written."/>
		<cfargument name="project" type="string" required="No" default="#variables.project#"
					hint="I am the database name which is used to name subdirectories."/>
		<cfargument name="lTables" type="string" required="No" default="#ArrayToList(getTablesFromXML())#"
					hint="I am a list of tables to be used to generate the code. If blank all tables defined in the XML will be used."/>
		
		<cfset var aTemplateFiles = ArrayNew(1)>
		<cfset var stFileData = structNew()>
		<cfset var i = 0>
		<cfset var thisTable = "">
		<cfset var thisAlias = "">
		
		<cfset setLTables(arguments.lTables)>
		
		<!--- Include the descriptor for the selected set of templates --->
		<cftry>
			<cfinclude template="../templates/#arguments.template#/templateDescriptor.cfm">
			<cfcatch type="MissingInclude">
				<cfthrow type="Template_Descriptor_Not_Found" message="The selected scaffolding template descriptor file '/templates/#arguments.template#/templateDescriptor.cfm' was not found." detail="#cfcatch.detail#">
			</cfcatch>
			<cfcatch type="Any">
				<cfthrow type="Template_Descriptor_Invalid" message="An error occured when executing the selected scaffolding template descriptor file. #cfcatch.message#" detail="An error occured when executing the selected scaffolding template descriptor file. #cfcatch.detail#">
			</cfcatch>
		</cftry>
		
		<!--- Update the progress bar --->
		<cfset cftemplate.progressReport(message="Beginning Code Generation.",progress=1,reset="true",fullProgress=(ListLen(arguments.lTables)+2))>
		
		<!--- For each of the templates where they are not created per object --->
		<cfloop index="i" from="1" to="#ArrayLen(aTemplateFiles)#">
			<cfif NOT aTemplateFiles[i].perObject>
				<cfset cftemplate.generateScript("#arguments.template#/#aTemplateFiles[i].templateFile#.#aTemplateFiles[i].suffix#",this,"#aTemplateFiles[i].MVCpath##aTemplateFiles[i].outputFile#.#aTemplateFiles[i].suffix#",aTemplateFiles[i].inPlace,aTemplateFiles[i].overwrite)>
			</cfif>
			<cfflush>
		</cfloop>
		
		<cfset cftemplate.incrementProgress()>
		
		<!--- Loop over objects and create code for each object --->
		<cfloop list="#arguments.lTables#" index="thisTable">
			<!--- Loop over the templates in the template description array --->
			<cfloop index="i" from="1" to="#ArrayLen(aTemplateFiles)#">
				<cfif aTemplateFiles[i].perObject>
					<!--- Find the alias we are going to use to name our files --->
					<cfset setSelectedTable(thisTable)>
					<cfset thisAlias = getSelectedTableAlias()>
					
					<!--- Work out if the generated filename depends on the object alias --->
					<cfif aTemplateFiles[i].useAliasInName><cfset aliasInName = thisAlias><cfelse><cfset aliasInName = ""></cfif>
					<!--- Generate the code --->
					<cfif aTemplateFiles[i].suffix IS "cfc" OR aTemplateFiles[i].suffix IS "as">
						<cfset cftemplate.generateScript("#arguments.template#/#aTemplateFiles[i].templateFile#.#aTemplateFiles[i].suffix#",this,"#aTemplateFiles[i].MVCpath##aliasInName##aTemplateFiles[i].outputFile#.#aTemplateFiles[i].suffix#",aTemplateFiles[i].inPlace,aTemplateFiles[i].overwrite)>
					<cfelse>
						<cfset cftemplate.generateScript("#arguments.template#/#aTemplateFiles[i].templateFile#.#aTemplateFiles[i].suffix#",this,"#aTemplateFiles[i].MVCpath##aTemplateFiles[i].outputFile##aliasInName#.#aTemplateFiles[i].suffix#",aTemplateFiles[i].inPlace,aTemplateFiles[i].overwrite)>
					</cfif>
				</cfif>
			</cfloop>
			<cfset cftemplate.incrementProgress()>
			<cfflush>
		</cfloop>
		<cfset cftemplate.progressReport(message="Completed Code Generation.",progress=(ListLen(arguments.lTables)+2),complete=true)>
		
		<cfreturn>
	</cffunction>
	
	<cffunction name="getTemplates" returntype="query" output="No" hint="I get a recordset containing the available templates.">
		<cfset var qTemplates = 0>
		
		<!--- Get a recordset of the subdirectories below the templates directory --->
		<cfdirectory action="LIST" directory="#GetDirectoryFromPath(getCurrentTemplatePath())#../templates/" name="qTemplates">
		<!--- Get only directories and ignore hidden ones so that SVN or CVS directories don't show up --->
		<cfquery name="qTemplates" dbtype="query">
			SELECT 	name 
			FROM 	qTemplates
			WHERE 	Type = 'Dir' 
				AND NOT Attributes LIKE '%H%'
		</cfquery>
		
		<cfreturn qTemplates>
	</cffunction>
	
<!--- *** 					*** --->
<!--- *** Utility Functions *** --->
<!--- *** 					*** --->

	<cffunction name="cleanLabelText" returntype="string" output="No" 
				hint="I process a field name to make a text label for the field by replacing any underscores with a space and putting spaces in front of Camel case words.">
		<cfargument name="text" required="Yes" type="string">
		
		<cfset var local = StructNew()>
		
		<!--- Replace underscores with spaces --->
		<cfset local.text = replace(arguments.text,"_"," ","all")>
		<!--- Look for uppercase letters in camel case names --->
		<cfset local.out = uCase(left(local.text,1))>
		<cfset local.charCount = len(local.text)>
		<cfloop index="local.i" from="2" to="#local.charCount#">
			<cfset local.value = asc(Mid(Text,local.i,1))>
			<cfset local.prev  = asc(Mid(Text,local.i-1,1))>
			<!--- Is this an uppercase character ? --->
			<cfif (local.value GE 65 AND local.value LE 90 AND local.prev GE 97 AND local.prev LE 122)>
				<!--- The character is uppercase so add a space --->
				<cfset local.out = local.out & " " & Mid(local.Text,local.i,1)>
			<cfelse>
				<cfset local.out = local.out & Mid(local.Text,local.i,1)>
			</cfif>
		</cfloop>
		
		<cfreturn local.out>
	</cffunction>
	
	<cffunction name="ArrayConcat" access="private" returntype="array" output="No" hint="I concatenate two arrays.">
		<cfargument name="a1" type="array" />
		<cfargument name="a2" type="array" />
		
		<cfset var i=1>
		<cfscript>
			if ((NOT IsArray(a1)) OR (NOT IsArray(a2))) {
				writeoutput("Error in <Code>ArrayConcat()</code>! Correct usage: ArrayConcat(<I>Array1</I>, <I>Array2</I>) -- Concatenates Array2 to the end of Array1");
				return 0;
			}
			for (i=1;i LTE ArrayLen(a2);i=i+1) {
				ArrayAppend(a1, Duplicate(a2[i]));
			}
		</cfscript>
		<cfreturn a1>
	</cffunction>
	
<!--- *** 							 *** --->
<!--- *** ColdFusion Admin Functions *** --->
<!--- *** 							 *** --->

	<cffunction name="GetAllDatasources" returntype="struct" output="No" 
				hint="I get a structure of all the available datasources.">
		<cfset var factory = 0>
		<cfset var dsService = 0>
		<cfset var stDatasources = 0>
		
		<!--- Get CF "factory" --->
		<cfobject action="CREATE" type="JAVA" class="coldfusion.server.ServiceFactory" name="factory">
		<!--- Get datasource service --->
		<cfset dsService=factory.getDataSourceService()>
		
		<cfset stDatasources = dsService.getDatasources()>
		
		<cfreturn stDatasources>
	</cffunction>
	
	<cffunction name="GetSupportedDatasourcesAsQuery" returntype="query" output="No" 
				hint="I get a recordset of the supported datasources.">
		<cfset var stDatasources = GetAllDatasources()>
		<cfset var qRawDatasources = QueryNew("Datasourcename,DBName,Driver,Buffer")>
		<cfset var thisDSN = 0>
		<cfset var qDatasources = 0>
		<cfset var stDBMSLookup = getSupportedDBMS()>
		
		<cfloop collection="#stDatasources#" item="thisDSN">
			<cfif structKeyExists(stDBMSLookup,stDatasources[thisDSN].driver)>
				<cfset QueryAddRow(qRawDatasources)>
				<cfset QuerySetCell(qRawDatasources,"Datasourcename",stDatasources[thisDSN].name)>
				<cfset QuerySetCell(qRawDatasources,"DBName",stDatasources[thisDSN].urlmap.database)>
				<cfset QuerySetCell(qRawDatasources,"Driver",stDBMSLookup[stDatasources[thisDSN].driver])>
				<cfset QuerySetCell(qRawDatasources,"Buffer",stDatasources[thisDSN].buffer)>
			</cfif>
		</cfloop>
		
		<cfquery name="qDatasources" dbtype="query">
			SELECT 	[Datasourcename],
					[DBName],
					[Driver],
					[Buffer]
			FROM 	qRawDatasources
			ORDER BY [Driver] ASC, [Datasourcename] ASC
		</cfquery>

		<cfreturn qDatasources>
	</cffunction>
	
	<cffunction name="getSupportedDBMS" returntype="struct" output="No" 
				hint="I create a look up structure of the supported DBMS">
		<cfset var stDBMSLookup = structNew()>
		<cfscript>
			// Set up a look up table for the dbms type.
			// The key is the value for the driver returned by the factory and the value is the name used by the scaffolding.
			stDBMSLookup["MSSQLServer"] = "mssql";
			//stDBMSLookup["mysql4"] = "mysql4";
			//stDBMSLookup["mysql"] = "mysql";
			//stDBMSLookup["db2"] = "db2";
			//stDBMSLookup["oracle"] = "oracle";
			//stDBMSLookup["oraclerdb"] = "oraclerdb";
			//stDBMSLookup["postgres"] = "postgres";
		</cfscript>
		<cfreturn stDBMSLookup>
	</cffunction>

<!--- 										 --->
<!--- *** DBMS Introspection Functions   *** --->
<!--- 										 --->

	<cffunction name="getTables" returntype="query" output="No" 
				hint="I get a recordset of tables available from the selected datasource">
		<cfargument name="datasource" required="No">
		<cfargument name="username" required="No">
		<cfargument name="password" required="No">
		
		<cfset var stDatasources = structNew()>
		<cfset var stDBMSLookup = getSupportedDBMS()>
		<cfset var dbType = "">
		
		<cfif isDefined("arguments.datasource")>
			<cfset stDatasources = GetAllDatasources()>
			<cfset dbType = trim(stDBMSLookup[stDatasources[arguments.datasource].driver])>
		<cfelse>
			<cfset dbType = variables.DbType>
		</cfif>
		
		<!--- SQL Server version of the code --->
		<cfif dbType IS NOT "">
			<cfset qTables = Evaluate("getTables#dbType#(argumentCollection=arguments)")>
		<cfelse>
			<!--- TODO: Add equivalent SQL for other DBMS --->
			<cfthrow type="Application" message="DBMS #attributes.type# is not yet supported.">
		</cfif>
		
		<!--- NOTE Returned query requires the following fields:
			TableName
		 --->
		
		<cfreturn qTables>
	</cffunction>
	
	<cffunction name="getTablesAsXML" returntype="XML"  output="No" 
				hint="I get the tables available from the selected datasource formatted as XML.">
		<cfargument name="datasource" required="No">
		<cfargument name="username" required="No">
		<cfargument name="password" required="No">
		<cfset var xTables = "">
		<cfset var qTables = "">
		
		<cfif arguments.datasource IS NOT "" AND arguments.datasource IS NOT "_null">
			<cfset qTables = getTables(argumentCollection = arguments)>
		<cfelse>
			<cfset qTables = QueryNew("TableName")>
		</cfif>
		
<cfxml variable="xTables">
<scaffolding>
	<config>
		<properties />
	</config>
	<objects>
		<cfoutput query="qTables">
		<object alias="#iif(Left(qTables.TableName,3) IS 'tbl','RemoveChars(qTables.TableName,1,3)','qTables.TableName')#" label="#cleanLabelText(qTables.TableName)#" name="#qTables.TableName#" />
		<!--- <object alias="#iif(Left(qTables.TableName,3) IS "tbl",RemoveChars(qTables.TableName,1,3),qTables.TableName)#" label="#cleanLabelText(qTables.TableName)#" name="#qTables.TableName#" /> --->
		</cfoutput>
	</objects>
</scaffolding>
</cfxml>
		
		<cfreturn xTables>
	</cffunction>
	
	<cffunction name="getProject" returntype="string" output="No" hint="I return the project name.">
		<cfreturn variables.project>
	</cffunction>
	
	<cffunction name="getTemplate" returntype="string" output="No" hint="I return the Template Type.">
		<cfreturn variables.template>
	</cffunction>
	
	<cffunction name="getDbName" returntype="string" output="No" hint="I return the DBMS Name">
		<cfreturn variables.DbName>
	</cffunction>
	
	<cffunction name="getDbType" returntype="string" output="No" hint="I return the DBMS Type">
		<cfreturn variables.DbType>
	</cffunction>
	
	<cffunction name="getBuffer" returntype="string" output="No" hint="I return the DBMS Driver Buffer Size">
		<cfreturn variables.DbBuffer>
	</cffunction>
	
	<cffunction name="getDatasource" returntype="string" output="No" hint="I return the Datasource Name.">
		<cfreturn variables.datasource>
	</cffunction>
	
	<cffunction name="getUsername" returntype="string" output="No" hint="I return the DBMS Username">
		<cfreturn variables.username>
	</cffunction>
	
	<cffunction name="getPassword" returntype="string" output="No" hint="I return the DBMS Password">
		<cfreturn variables.password>
	</cffunction>
	
	<cffunction name="getAuthor" returntype="string" output="No" hint="I return the authors name">
		<cfreturn variables.author>
	</cffunction>
	
	<cffunction name="getAuthorEmail" returntype="string" output="No" hint="I return the authors email address">
		<cfreturn variables.authorEmail>
	</cffunction>
	
	<cffunction name="getCopyright" returntype="string" output="No" hint="I return the copyright statement">
		<cfreturn variables.copyright>
	</cffunction>
	
	<cffunction name="getLicence" returntype="string" output="No" hint="I return the licence text">
		<cfreturn variables.licence>
	</cffunction>
	
	<cffunction name="getVersion" returntype="string" output="No" hint="I return the version information">
		<cfreturn variables.version>
	</cffunction>
	
	<cffunction name="getTablesMSSQL" returntype="query" output="No" hint="I get a recordset of tables available from the selected datasource">
		<cfargument name="datasource" required="No" default="#getDatasource()#">
		<cfargument name="username" required="No" default="#getUsername()#">
		<cfargument name="password" required="No" default="#getPassword()#">
		
		<cfset var qTables = 0>
		
		<cfquery name="qTables" datasource="#arguments.datasource#" 
				username="#arguments.username#" password="#arguments.password#">
			SELECT 	Name AS tableName,
					Type AS tableType
			FROM 	SYSOBJECTS
			WHERE 	OBJECTPROPERTY(ID, N'IsUserTable') = 1
				AND Name != 'dtproperties'
		</cfquery>
		
		<cfreturn qTables>
	</cffunction>
	
	<cffunction name="getFields" returntype="query" output="No" 
				hint="I return a query containing the fields of the selected table.">
		<cfargument name="tableName" type="string" required="Yes">
		<cfargument name="datasource" required="No" default="#variables.datasource#" type="string" hint="I am a datasource name.">
		<cfargument name="username" required="No" default="#variables.username#" type="string" hint="I am the username.">
		<cfargument name="password" required="No" default="#variables.password#" type="string" hint="I am the password.">
		
		<cfset var qFields = 0>
		<cfset var stDatasources = GetAllDatasources()>
		<cfset var stDBMSLookup = getSupportedDBMS()>
		<cfset var DBType = stDBMSLookup[stDatasources[arguments.datasource].driver]>
		
		<cfset qFields = Evaluate("getFields#DBType#(arguments.tableName,arguments.datasource,arguments.username,arguments.password)")>
		
		<!--- NOTE Returned query requires the following fields:
			Column_Name,
			Nullable,
			Length,
			Type_Name,
			Ordinal_Position,
			Key_Seq
		 --->
		<cfreturn qFields>
	</cffunction>
	
	<cffunction name="getFieldsMSSQL" returntype="query" output="No" 
				hint="I return a query containing the fields of the selected MSSQL table.">
		<cfargument name="tableName" type="string" required="Yes">
		<cfargument name="datasource" required="Yes" type="string" hint="I am a datasource name.">
		<cfargument name="username" required="No" default="" type="string" hint="I am the username.">
		<cfargument name="password" required="No" default="" type="string" hint="I am the password.">
		
		<!--- Local variables --->
		<cfset var qFieldsRaw = 0>
		<cfset var qPKFields = 0>
		<cfset var qFields = 0>
		<cfset var lPKFields = "">
		
		<cfquery name="qFieldsRaw" datasource="#arguments.datasource#" username="#arguments.username#" password="#arguments.password#">
			sp_columns '#arguments.tableName#'
		</cfquery>
		
		<cfquery name="qPKFields" datasource="#arguments.datasource#" username="#arguments.username#" password="#arguments.password#">
			sp_pkeys '#arguments.tableName#'
		</cfquery>
		
		<cfquery name="qSpecialFields" datasource="#arguments.datasource#" username="#arguments.username#" password="#arguments.password#">
			sp_special_columns '#arguments.tableName#'
		</cfquery>
		
		<cfset lPKFields = QuotedValueList(qPKFields.Column_Name)>
		
		<cfquery name="qFields" dbtype="query">
			SELECT 	qFieldsRaw.Column_Name,
					Nullable,
					Length,
					Type_Name,
					Ordinal_Position,
					Key_Seq
			FROM 	qFieldsRaw, qPKFields
				WHERE qFieldsRaw.Column_Name = qPKFields.Column_Name
				
			  UNION 
			
			SELECT 	Column_Name,
					Nullable,
					Length,
					Type_Name,
					Ordinal_Position,
					0
			FROM 	qFieldsRaw
				WHERE 0=0
				<cfloop list="#lPKFields#" index="thisField">
				AND NOT qFieldsRaw.Column_Name = #preservesinglequotes(thisField)#</cfloop>
			
			ORDER BY Ordinal_Position
		</cfquery>
		<cfreturn qFields>
	</cffunction>
	
	<cffunction name="getParentRelationships" returntype="query" output="No" 
				hint="I return a query containing the parent relationships for the selected table.">
		<cfargument name="tableName" type="string" required="Yes">
		<cfargument name="datasource" required="No" default="#variables.datasource#" type="string" hint="I am a datasource name.">
		<cfargument name="username" required="No" default="#variables.username#" type="string" hint="I am the username.">
		<cfargument name="password" required="No" default="#variables.password#" type="string" hint="I am the password.">
		
		<cfset var stDatasources = GetAllDatasources()>
		<cfset var stDBMSLookup = getSupportedDBMS()>
		<cfset var DBType = stDBMSLookup[stDatasources[arguments.datasource].driver]>
		
		<cfset var qFKFields = Evaluate("getParentRelationships#DBType#(arguments.datasource,arguments.tableName,arguments.username,arguments.password)")>
		
		<!--- NOTE Returned query requires the following fields:
			
		 --->
		<cfreturn qFKFields>
		
	</cffunction>
	
	<cffunction name="getParentRelationshipsMSSQL" returntype="query" output="No" 
				hint="I return a query containing the parent relationships for the selected table.">
		<cfargument name="datasource" required="Yes" type="string" hint="I am a datasource name.">
		<cfargument name="tableName" type="string" required="Yes">
		<cfargument name="username" required="No" default="" type="string" hint="I am the username.">
		<cfargument name="password" required="No" default="" type="string" hint="I am the password.">
		
		<cfset var qPKFields=0>
		
		<cfquery name="qFKFields" datasource="#arguments.datasource#" username="#arguments.username#" password="#arguments.password#">
			sp_fkeys @fktable_name = '#arguments.tableName#'
		</cfquery>
		
		<cfreturn qFKFields>
		
	</cffunction>
	
	<cffunction name="getChildRelationships" returntype="query" output="No" 
				hint="I return a query containing the child relationships for the selected table.">
		<cfargument name="tableName" type="string" required="Yes">
		<cfargument name="datasource" required="No" default="#variables.datasource#" type="string" hint="I am a datasource name.">
		<cfargument name="username" required="No" default="#variables.username#" type="string" hint="I am the username.">
		<cfargument name="password" required="No" default="#variables.password#" type="string" hint="I am the password.">
		
		<cfset var stDatasources = GetAllDatasources()>
		<cfset var stDBMSLookup = getSupportedDBMS()>
		<cfset var DBType = stDBMSLookup[stDatasources[arguments.datasource].driver]>
		
		<cfset var qPKFields = Evaluate("getChildRelationships#DBType#(arguments.datasource,arguments.tableName,arguments.username,arguments.password)")>
		
		<!--- NOTE Returned query requires the following fields:
			
		 --->
		<cfreturn qPKFields>
		
	</cffunction>
	
	<cffunction name="getChildRelationshipsMSSQL" returntype="query" output="No" 
				hint="I return a query containing the child relationships for the selected table.">
		<cfargument name="datasource" required="Yes" type="string" hint="I am a datasource name.">
		<cfargument name="tableName" type="string" required="Yes">
		<cfargument name="username" required="No" default="" type="string" hint="I am the username.">
		<cfargument name="password" required="No" default="" type="string" hint="I am the password.">
		<cfset var qPKFields=0>
		
		<cfquery name="qPKFields" datasource="#arguments.datasource#" username="#arguments.username#" password="#arguments.password#">
			sp_fkeys @pktable_name = '#arguments.tableName#'
		</cfquery>
		
		<cfreturn qPKFields>
		
	</cffunction>
	
<!--- *** 													  **** --->
<!--- *** The following functions Read and write the XML file **** --->
<!--- *** 													  **** --->
	
	<cffunction name="read" returntype="any" output="No" hint="I read the XML Metadata file and populate the local copy.">
		<cfargument name="configFilePath" default="#variables.configFilePath#" required="Yes" >
		
		<cfset var configFile = "">
		<cfset var theError = "">
		<cfoutput>Read the file<br /></cfoutput>
		<cfif fileexists(arguments.configFilePath)><cfoutput>HERE</cfoutput>
			<cftry>
				<cffile action="READ" file="#arguments.configFilePath#" variable="configFile">
				<cfcatch>
					<cfset theError = structNew()>
					<cfset theError.message="The XML config file was not found.">
					<cfset theError.detail="The XML config file (#arguments.configFilePath#) was not found.">
					<cfthrow type="Application" message="#theError.message#" detail="#theError.message#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfset variables.xScaffoldingConfig = xmlParse(configFile)>
				<cfcatch>
					<cfset theError = structNew()>
					<cfset theError.message="The XML config file is not valid.">
					<cfset theError.detail="The XML config file (#arguments.configFilePath#) is not valid.">
					<cfthrow type="Application" message="#theError.message#" detail="#theError.message#">
				</cfcatch>
			</cftry>
			
			<cfset getConfigFromXML()>
			
		<cfelse>
			<cfset variables.xScaffoldingConfig = xmlNew()>
			<cfset variables.xScaffoldingConfig.scaffolding = xmlElemNew(variables.xScaffoldingConfig,"scaffolding")>
			<cfset variables.xScaffoldingConfig.scaffolding.config = xmlElemNew(variables.xScaffoldingConfig,"config")>
			<cfset variables.xScaffoldingConfig.scaffolding.objects = xmlElemNew(variables.xScaffoldingConfig,"objects")>
		</cfif>
		
		<cfreturn variables.xScaffoldingConfig>
	</cffunction>

	<cffunction name="save" returntype="boolean" output="No" hint="I save the XML Metadata.">
		<cfargument name="configFilePath" required="No" default="#variables.configFilePath#">
		<cfset var temp = setConfigInXML()>
		<cfset var outstring = toString(variables.xScaffoldingConfig)>
		
		<cfif arguments.configFilePath IS "">
			<cfthrow type="Fusebox_Scaffolding_Config" message="Undefined configuration file path." detail="The configuration file path is empty.">
		</cfif>
		
		<!--- Format the XML nicely - This is a bit of a hack but puts the right number of line breaks and spaces in front of each tag. --->
		<cfset outstring = REReplace(outstring,">[[:space:]]*</scaffolding",">#chr(13)#</scaffolding","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<config",">#chr(13)##chr(9)#<config","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*</config>",">#chr(13)##chr(9)#</config>","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<properties",">#chr(13)##chr(9)##chr(9)#<properties","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<project ",">#chr(13)##chr(13)##chr(9)##chr(9)#<project ","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*</project>",">#chr(13)##chr(9)##chr(9)#</project>","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<datasource ",">#chr(13)##chr(13)##chr(9)##chr(9)#<datasource ","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*</datasource>",">#chr(13)##chr(9)##chr(9)#</datasource>","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<template ",">#chr(13)##chr(13)##chr(9)##chr(9)#<template ","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*</template>",">#chr(13)##chr(9)##chr(9)#</template>","all") >
		
		<cfset outstring = REReplace(outstring,">[[:space:]]*<objects",">#chr(13)##chr(13)##chr(9)#<objects","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*</objects>",">#chr(13)##chr(9)#</objects>","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<object ",">#chr(13)##chr(13)##chr(9)##chr(9)#<object ","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*</object>",">#chr(13)##chr(9)##chr(9)#</object>","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<manyTo",">#chr(13)##chr(9)##chr(9)##chr(9)#<manyTo","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*</manyTo",">#chr(13)##chr(9)##chr(9)##chr(9)#</manyTo","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<oneTo",">#chr(13)##chr(9)##chr(9)##chr(9)#<oneTo","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*</oneTo",">#chr(13)##chr(9)##chr(9)##chr(9)#</oneTo","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<relate",">#chr(13)##chr(9)##chr(9)##chr(9)##chr(9)#<relate","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<link",">#chr(13)##chr(9)##chr(9)##chr(9)##chr(9)#<link","all") >
		<cfset outstring = REReplace(outstring,">[[:space:]]*<field",">#chr(13)##chr(9)##chr(9)##chr(9)#<field","all") >
		
		<cffile action="WRITE" 
				file="#arguments.configFilePath#" 
				output="#outstring#" 
				addnewline="Yes">
		
		<cfreturn true>
	</cffunction>
	
	<!--- *** Create or update the configuration entries in the XML *** --->
	<cffunction name="setConfigInXML" returntype="boolean" output="No" hint="I set up the basic configuration information in the XML.">
		<cfset var fieldlist="project,datasource,username,password,template,author,authorEmail,copyright,licence,version">
		
		<!--- Loop over the fields and update the XML --->
		<cfloop list="#fieldlist#" index="thisField">
			<cfif NOT structKeyExists(variables.xScaffoldingConfig.scaffolding.config,"properties")>
				<cfset variables.xScaffoldingConfig.scaffolding.config["properties"] = XmlElemNew(xScaffoldingConfig,"properties")>
			</cfif>
			<!--- Look to see if the field exists --->
			<cfif isDefined("variables.#thisField#") AND trim(variables[thisField]) IS NOT "" >
				<!--- Update the XML document object element or create a new one --->
				<cfset variables.xScaffoldingConfig.scaffolding.config["properties"].XmlAttributes[thisField] = variables[thisField]>
			</cfif>
		</cfloop>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getConfigFromXML" returntype="boolean" output="Yes" hint="I get the basic configuration information from the XML.">
		<cfset var fieldlist="project,datasource,username,password,template,author,authorEmail,copyright,licence,version">
		
		<cfif isDefined("variables.xScaffoldingConfig.scaffolding.config.properties")>
		<cfloop list="#fieldlist#" index="thisField">
			
			<cfif structKeyExists(variables.xScaffoldingConfig.scaffolding.config.properties.XmlAttributes,thisField) >
				<cfset "variables.#thisField#"=variables.xScaffoldingConfig.scaffolding.config["properties"].XmlAttributes[thisField]>
			<cfelse>
				<cfset "variables.#thisField#"="">
			</cfif>
		</cfloop>
		</cfif>
		
		<cfreturn true>
	</cffunction>
	
	<!--- *** Find and create object entries in the XML *** --->
	<cffunction name="getObjectPosition" returntype="numeric" output="No" 
				hint="I look for an object by name or alias in the XML and return its position, if not found zero is returned.">
		<cfargument name="name" type="string" required="No" default="" >
		<cfargument name="alias" type="string" required="No" default="" >
		
		<!--- Get the array of objects --->
		<cfset var aObjects = variables.xScaffoldingConfig.scaffolding.objects.xmlChildren>
		<cfset var objectCount = ArrayLen(aObjects)>
		<cfset var thisIndex = 0>
		<cfset var i = 0>
		
		<!--- Look for the object in the array --->
		<cfloop from="1" to="#objectCount#" index="i">
			<cfif arguments.name IS NOT "" AND aObjects[i].XmlAttributes.name IS arguments.name>
				<cfset thisIndex = i>
				<cfbreak>
			<cfelseif arguments.alias IS NOT "" AND aObjects[i].XmlAttributes.alias IS arguments.alias>
				<cfset thisIndex = i>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfreturn thisIndex>
	</cffunction>
	
	<cffunction name="createObjectTag" returntype="numeric" output="No" 
				hint="I check if an object exists, if not I create the object in the XML and return its position.">
		<cfargument name="name" type="string" required="Yes" >
		<cfargument name="alias" type="string" required="No" default="#arguments.name#" >
		<cfargument name="label" type="string" required="No" default="#arguments.alias#" >
		
		<!--- See if the object already exists --->
		<cfset var thisIndex = getObjectPosition(name=arguments.name)>
		
		<!--- If the object wasn't found then add it and set the name, alias and label --->	
		<cfif thisIndex IS 0>
			<cfset ArrayAppend(xScaffoldingConfig.scaffolding.objects.XmlChildren,XmlElemNew(xScaffoldingConfig,"object"))>
			<!--- New objects allways get added at the end of the array --->
			<cfset thisIndex = ArrayLen(variables.xScaffoldingConfig.scaffolding.objects.xmlChildren)>
			<cfset variables.xScaffoldingConfig.scaffolding.objects.object[thisIndex].XmlAttributes["name"] = arguments.name>
			<cfset variables.xScaffoldingConfig.scaffolding.objects.object[thisIndex].XmlAttributes["alias"] = arguments.alias>
			<cfset variables.xScaffoldingConfig.scaffolding.objects.object[thisIndex].XmlAttributes["label"] = arguments.label>
		</cfif>
		
		<cfreturn thisIndex>
	</cffunction>
	
	<cffunction name="createObjectTags" returntype="void" output="No" 
				hint="I create an object in the XML for each table in the list.">
		<cfargument name="lTables" type="string" required="Yes" hint="I am the list of tables.">
		<cfset var thisTable = "">
		<cfset var thisAlias = "">
		
		<cfloop list="#arguments.lTables#" index="thisTable">
			<!--- If the table name starts with tbl remove it --->
			<cfif left(thisTable,3) IS "tbl"><cfset thisAlias = removeChars(thisTable,1,3)><cfelse><cfset thisAlias = thisTable></cfif>
			<cfset createObjectTag(thisTable,thisAlias,cleanLabelText(thisAlias))>
		</cfloop>
	</cffunction>
	
	<!--- *** Find and create the fields in the XML within an object *** --->
	<cffunction name="getFieldPosition" returntype="numeric" output="No" 
				hint="I look up the field by name or alias and return its position within the object, if not found return zero.">
		<cfargument name="objectIndex" type="numeric" required="Yes" >
		<cfargument name="name" type="string" required="No" default="">
		<cfargument name="alias" type="string" required="No" default="">
		
		<cfset var aObjectChildren = "">
		<cfset var objectChildCount =  0>
		<cfset var j = 0>
		<cfset var thisFieldIndex = 0>
		
		<cfif isDefined("variables.xScaffoldingConfig.scaffolding.objects.object") AND arguments.objectIndex GT 0>
			<cfset aObjectChildren = variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren>
			<cfset objectChildCount =  ArrayLen(aObjectChildren)>
		<cfelse>
			<cfreturn 0>
		</cfif>
		
		<!--- Look for the field in the array --->
		<cfloop from="1" to="#objectChildCount#" index="j">
			<!--- <cfoutput>#aObjectChildren[j].XmlName# - #aObjectChildren[j].XmlAttributes.name#<br /></cfoutput> --->
			<cfif arguments.name IS NOT ""
			  AND aObjectChildren[j].XmlName IS "field"
			  AND aObjectChildren[j].XmlAttributes.name IS arguments.name>
				<cfset thisFieldIndex = j>
				<cfbreak>
			<cfelseif arguments.alias IS NOT ""
			  AND aObjectChildren[j].XmlName IS "field"
			  AND structKeyExists(aObjectChildren[j].XmlAttributes,"alias")
			  AND aObjectChildren[j].XmlAttributes.alias IS arguments.alias>
				<cfset thisFieldIndex = j>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfreturn thisFieldIndex>
	</cffunction>
	
	<cffunction name="createFieldTag" returntype="numeric" output="No" 
				hint="I find or create a single field within an object in the XML and return its position.">
		<cfargument name="objectIndex" required="Yes" type="numeric">
		<cfargument name="name" type="string" required="Yes" >
		<cfargument name="alias" type="string" required="No" default="#arguments.name#">
		<cfargument name="label" type="string" required="No" default="#cleanLabelText(arguments.alias)#" >
		
		<cfset var thisFieldIndex = getFieldPosition(objectIndex=arguments.objectIndex,name=arguments.name)>
		<cfset var aObjectChildren = variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren>
		<cfset var objectChildIndex = ArrayLen(aObjectChildren)>
		
		<!--- If the field isn't there add it --->
		<cfif thisFieldIndex IS 0>
			<cfset ArrayAppend(variables.xScaffoldingConfig.scaffolding.objects.XmlChildren[arguments.objectIndex].XmlChildren,XmlElemNew(xScaffoldingConfig,"field"))>
			<!--- New fields always get added at the end of the array --->
			<cfset objectChildIndex = objectChildIndex + 1>
			<cfset variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[objectChildIndex].XmlAttributes["name"] = arguments.name>
			<cfset variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[objectChildIndex].XmlAttributes["alias"] = arguments.alias>
			<cfset variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[objectChildIndex].XmlAttributes["label"] = arguments.label>
			<cfset thisFieldIndex = objectChildIndex>
		</cfif>
		
		<cfreturn thisFieldIndex>
	</cffunction>
	
	<!--- *** Create or update the other field properties *** --->
	<cffunction name="setAttributeValue" returntype="string" output="No" 
				hint="I update, create or remove the value of an XML attribite.">
		<cfargument name="stProperties" required="Yes" type="struct" 
			hint="I am a pointer to the structure containing the attributes of the XML tag to be updated." >
		<cfargument name="attribute" required="Yes" type="string" hint="Attribute name to be updated.">
		<cfargument name="value" required="Yes" type="any" hint="The new attribute value">
		<cfargument name="rule" required="No" type="string" default="noOverwrite" hint="Rule to be followed eg: Overwrite,noOverwrite.">
		
		<cfif StructKeyExists(arguments.stProperties,arguments.attribute)>
			<cfif arguments.rule DOES NOT CONTAIN "noOverwrite" AND arguments.value IS NOT "" >
				<cfset arguments.stProperties[arguments.attribute] = arguments.value>
			<cfelseif arguments.rule DOES NOT CONTAIN "noOverwrite" AND arguments.value IS "">
				<cfset structDelete(arguments.stProperties,arguments.attribute)>
				<cfreturn "">
			</cfif>
		<cfelse>
			<cfif arguments.value IS NOT "" >
				<cfset arguments.stProperties[arguments.attribute] = arguments.value>
			<cfelse>
				<cfreturn "">
			</cfif>
		</cfif>
		<cfreturn arguments.stProperties[arguments.attribute]>
	</cffunction>
	
	<cffunction name="updateBaseFieldPropertiesFromQuery" returntype="void" output="No" 
				hint="I add or update the basic metadata properties for all fields in a table required by the scaffolding.">
		<cfargument name="tableName" required="Yes" type="string" hint="Name of the table.">
		<cfargument name="qTableData" required="Yes" type="query" hint="A Query containing the data for each field.">
		
		<cfset var thisFieldIndex = 0>
		<cfset var stProperties = structNew()>
		
		<!--- The query from MSSQL contains COLUMN_NAME,KEY_SEQ,LENGTH,NULLABLE,ORDINAL_POSITION,TYPE_NAME  --->
		
		<!--- Example of a typical field tag:
		 <field	name="TagId" 
		 		alias="TagId" 
				label="Tag Id" 
				fuseDocType="integer" 
				type="Number"
				SQLType="CF_SQL_INTEGER"
				formType="Hidden" 
				format="Number(0)" 
				required="false" 
				showOnForm="true" 
				showOnList="true" 
				size="0" 
				sort="1" 
				primaryKeySeq="1" 
				identity="true" 
		 />
		 --->
		
		<!--- Find the object that is being updated --->
		<cfset var objectIndex = getObjectPosition(name=arguments.tableName)>
		<cfset var stType = structNew()>
		<cfset var stFuseDocType = structNew()>
		<cfset var stSQLType = structNew()>
		
		<!--- Create a ColdFusion type lookup for MSSQL --->
		<cfset stType["bigint"] = "numeric">
		<cfset stType["binary"] = "numeric">
		<cfset stType["bit"] = "boolean">
		<cfset stType["char"] = "string">
		<cfset stType["datetime"] = "date">
		<cfset stType["decimal"] = "numeric">
		<cfset stType["float"] = "numeric">
		<cfset stType["image"] = "numeric">
		<cfset stType["int"] = "numeric">
		<cfset stType["money"] = "numeric">
		<cfset stType["nchar"] = "string">
		<cfset stType["ntext"] = "string">
		<cfset stType["numeric"] = "numeric">
		<cfset stType["nvarchar"] = "string">
		<cfset stType["real"] = "numeric">
		<cfset stType["smalldatetime"] = "date">
		<cfset stType["smallint"] = "numeric">
		<cfset stType["smallmoney"] = "numeric">
		<cfset stType["sql_variant"] = "numeric">
		<cfset stType["text"] = "string">
		<cfset stType["timestamp"] = "numeric">
		<cfset stType["tinyint"] = "numeric">
		<cfset stType["uniqueidentifier"] = "string">
		<cfset stType["varbinary"] = "numeric">
		<cfset stType["varchar"] = "string">
		<cfset stType["xml"] = "string">
		
		<!--- Create a FuseDoc type lookup for MSSQL --->
		<cfset stFuseDocType["bigint"] = "integer">
		<cfset stFuseDocType["binary"] = "binary">
 		<cfset stFuseDocType["bit"] = "boolean">
 		<cfset stFuseDocType["char"] = "string">
		<cfset stFuseDocType["datetime"] = "datetime">
		<cfset stFuseDocType["decimal"] = "number">
		<cfset stFuseDocType["float"] = "number">
		<cfset stFuseDocType["image"] = "binary">
		<cfset stFuseDocType["int"] = "integer">
		<cfset stFuseDocType["money"] = "number">
 		<cfset stFuseDocType["nchar"] = "string">
 		<cfset stFuseDocType["ntext"] = "string">
		<cfset stFuseDocType["numeric"] = "number">
 		<cfset stFuseDocType["nvarchar"] = "string">
		<cfset stFuseDocType["real"] = "number">
 		<cfset stFuseDocType["smalldatetime"] = "datetime">
		<cfset stFuseDocType["smallint"] = "integer">
		<cfset stFuseDocType["smallmoney"] = "number">
		<cfset stFuseDocType["sql_variant"] = "number">
 		<cfset stFuseDocType["text"] = "string">
		<cfset stFuseDocType["timestamp"] = "datetime">
		<cfset stFuseDocType["tinyint"] = "integer">
 		<cfset stFuseDocType["uniqueidentifier"] = "string">
		<cfset stFuseDocType["varbinary"] = "binary">
 		<cfset stFuseDocType["varchar"] = "string">
		<cfset stFuseDocType["xml"] = "string">
		
		<!--- Create a SQLtype lookup for MSSQL--->
		<cfset stSQLType["bigint"] = "CF_SQL_BIGINT">
		<cfset stSQLType["binary"] = "CF_SQL_BINARY">
		<cfset stSQLType["bit"] = "CF_SQL_BIT">
		<cfset stSQLType["char"] = "CF_SQL_CHAR">
		<cfset stSQLType["datetime"] = "CF_SQL_TIMESTAMP">
		<cfset stSQLType["decimal"] = "CF_SQL_DECIMAL">
		<cfset stSQLType["float"] = "CF_SQL_FLOAT">
		<cfset stSQLType["image"] = "CF_SQL_BINARY">
		<cfset stSQLType["int"] = "CF_SQL_INTEGER">
		<cfset stSQLType["money"] = "CF_SQL_MONEY">
		<cfset stSQLType["nchar"] = "CF_SQL_CHAR">
		<cfset stSQLType["ntext"] = "CF_SQL_VARCHAR">
		<cfset stSQLType["numeric"] = "CF_SQL_DECIMAL">
		<cfset stSQLType["nvarchar"] = "CF_SQL_VARCHAR">
		<cfset stSQLType["real"] = "CF_SQL_DECIMAL">
		<cfset stSQLType["smalldatetime"] = "CF_SQL_TIMESTAMP">
		<cfset stSQLType["smallint"] = "CF_SQL_SMALLINT">
		<cfset stSQLType["smallmoney"] = "CF_SQL_MONEY4">
		<cfset stSQLType["sql_variant"] = "CF_SQL_DECIMAL">
		<cfset stSQLType["text"] = "CF_SQL_VARCHAR">
		<cfset stSQLType["timestamp"] = "CF_SQL_TIMESTAMP">
		<cfset stSQLType["tinyint"] = "CF_SQL_TINYINT">
		<cfset stSQLType["uniqueidentifier"] = "CF_SQL_CHAR">
		<cfset stSQLType["varbinary"] = "CF_SQL_BINARY">
		<cfset stSQLType["varchar"] = "CF_SQL_VARCHAR">
		<cfset stSQLType["xml"] = "CF_SQL_VARCHAR">

		<!--- Loop over the fields and set the default properties of each --->
		<cfloop query="arguments.qTableData">
			<!--- Find the field tag position or create a new one --->
			<cfset thisFieldIndex = createFieldTag(objectIndex=objectIndex,name=arguments.qTableData.column_name)>
			
			<!--- Set up a pointer to the structure containing the attributes of the field tag in the XML --->
			<cfset stProperties = variables.xScaffoldingConfig.scaffolding.objects.object[objectIndex].XmlChildren[thisFieldIndex].XmlAttributes >
			
			<!--- Update the identity, type and primaryKeySeq attributes, exsiting values are always overwritten --->
			<cfif arguments.qTableData.type_name CONTAINS "identity">
				<cfset setAttributeValue(stProperties,"identity","true","overwrite") >
				<cfset setAttributeValue(stProperties,"type",stType[trim(replace(arguments.qTableData.type_name,"identity",""))],"overwrite")>
				<cfset setAttributeValue(stProperties,"sqlType",stSQLType[trim(replace(arguments.qTableData.type_name,"identity",""))],"overwrite")>
				<cfset setAttributeValue(stProperties,"fuseDocType",stFuseDocType[trim(replace(arguments.qTableData.type_name,"identity",""))],"overwrite")>
			<cfelse>
				<cfset setAttributeValue(stProperties,"type",stType[arguments.qTableData.type_name],"overwrite")>
				<cfset setAttributeValue(stProperties,"sqlType",stSQLType[arguments.qTableData.type_name],"overwrite")>
				<cfset setAttributeValue(stProperties,"fuseDocType",stFuseDocType[arguments.qTableData.type_name],"overwrite")>
			</cfif>
			
			<cfset setAttributeValue(stProperties,"primaryKeySeq",arguments.qTableData.key_seq,"overwrite")>
			
		</cfloop>
	</cffunction>	
	
	<cffunction name="updateAdditionalFieldPropertiesFromQuery" returntype="void" output="No" 
				hint="I add or update the additional metadata properties for all fields in a table required by the scaffolding.">
		<cfargument name="tableName" required="Yes" type="string" hint="Name of the table.">
		<cfargument name="qTableData" required="Yes" type="query" hint="A Query containing the data for each field.">
		
		<cfset var thisFieldIndex = 0>
		<cfset var stProperties = structNew()>
		<cfset var objectIndex = getObjectPosition(name=arguments.tableName)>
		
		<cfloop query="arguments.qTableData">
			<!--- Find the field tag position or create a new one --->
			<cfset thisFieldIndex = createFieldTag(objectIndex=objectIndex,name=arguments.qTableData.column_name)>
			
			<!--- Set up a pointer to the structure containing the attributes of the field tag in the XML --->
			<cfset stProperties = variables.xScaffoldingConfig.scaffolding.objects.object[objectIndex].XmlChildren[thisFieldIndex].XmlAttributes >
			
			<!--- The values of other XML attribute values never get overwritten --->
			<cfset setAttributeValue(stProperties,"sort",arguments.qTableData.key_seq)>
			<cfset setAttributeValue(stProperties,"showOnList","true")>
			<cfset setAttributeValue(stProperties,"showOnForm","true")>
			<cfif arguments.qTableData.nullable>
				<cfset setAttributeValue(stProperties,"required","false")>
			<cfelse>
				<cfset setAttributeValue(stProperties,"required","true")>
			</cfif>
			
			<!--- The values of formType, format, size, maxlength depend on various rules but existing values never get overwritten --->
			<cfif stProperties.type IS "date" AND arguments.qTableData.column_name CONTAINS "time">
				<cfset setAttributeValue(stProperties,"formType","Time")>
				<cfset setAttributeValue(stProperties,"format","Time")>
				<cfset setAttributeValue(stProperties,"size","15")>
				<cfset setAttributeValue(stProperties,"maxlength",8)>
			<cfelseif stProperties.type IS "date">
				<cfset setAttributeValue(stProperties,"formType","Date")>
				<cfset setAttributeValue(stProperties,"format","Date")>
				<cfset setAttributeValue(stProperties,"size","15")>
				<cfset setAttributeValue(stProperties,"maxlength",11)>
			<cfelseif isDefined("stProperties.parent") AND stProperties.parent IS NOT "">
				<cfset setAttributeValue(stProperties,"formType","Dropdown")>
				<cfset setAttributeValue(stProperties,"format","Trim")>
				<cfset setAttributeValue(stProperties,"size","1")>
			<cfelseif stProperties.type IS "boolean">
				<cfset setAttributeValue(stProperties,"formType","Checkbox")>
				<cfset setAttributeValue(stProperties,"format","YesNo")>
				<cfset setAttributeValue(stProperties,"size","0")>
			<cfelseif isDefined("stProperties.identity") AND stProperties.identity>
				<cfset setAttributeValue(stProperties,"formType","Hidden")>
				<cfset setAttributeValue(stProperties,"format","None")>
				<cfset setAttributeValue(stProperties,"size","0")>
			<cfelseif arguments.qTableData.type_name IS "money">
				<cfset setAttributeValue(stProperties,"formType","Text")>
				<cfset setAttributeValue(stProperties,"format","Currency")>
				<cfset setAttributeValue(stProperties,"size","15")>
				<cfset setAttributeValue(stProperties,"maxlength",15)>
			<cfelseif stProperties.fuseDocType IS "integer">
				<cfset setAttributeValue(stProperties,"formType","Text")>
				<cfset setAttributeValue(stProperties,"format","Integer")>
				<cfset setAttributeValue(stProperties,"size","15")>
				<cfset setAttributeValue(stProperties,"maxlength",15)>
			<cfelseif stProperties.type IS "numeric">
				<cfset setAttributeValue(stProperties,"formType","Text")>
				<cfset setAttributeValue(stProperties,"format","Number(9.99)")>
				<cfset setAttributeValue(stProperties,"size","15")>
				<cfset setAttributeValue(stProperties,"maxlength",15)>
			<cfelseif arguments.qTableData.length gt 200>
				<cfset setAttributeValue(stProperties,"formType","Textarea")>
				<cfset setAttributeValue(stProperties,"format","Trim")>
				<cfset setAttributeValue(stProperties,"size","30x4")>
				<cfset setAttributeValue(stProperties,"maxlength",min(arguments.qTableData.length,getBuffer()))>
			<cfelse>
				<cfset setAttributeValue(stProperties,"formType","Text")>
				<cfset setAttributeValue(stProperties,"format","Trim")>
				<cfset setAttributeValue(stProperties,"size","30")>
				<cfset setAttributeValue(stProperties,"maxlength",min(arguments.qTableData.length,getBuffer()))>
			</cfif>
			
		</cfloop>
	</cffunction>
	
	<!--- *** Find and create the relationships in the XML within an object *** --->
	<cffunction name="getRelationshipPosition" returntype="numeric" output="No" 
				hint="I look up the relationship by fkName, name or alias and return its position within the object, if not found return zero.">
		<cfargument name="objectIndex" type="numeric" required="Yes" />
		<cfargument name="name" type="string" required="No" default="" hint="I am the alias of the related object."/>
		<cfargument name="alias" type="string" required="No" default="" hint="I am an alternate name for this relationship."/>
		<cfargument name="fkName" type="string" required="No" default="" hint="The name of the foreign key in the database."/>
		<cfargument name="lTypes" type="string" required="No" default="oneToMany,oneToOne,manyToOne,oneToOne" hint="List of the types of realtionship to search for. Default is all." />
		
		<cfset var aObjectChildren = variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren>
		<cfset var objectChildCount =  ArrayLen(aObjectChildren)>
		<cfset var j = 0>
		<cfset var thisFieldIndex = 0>
		
		<!--- Look for the relationship in the array --->
		<cfloop from="1" to="#objectChildCount#" index="j">
			<cfif arguments.fkName IS NOT ""
			  AND ListFindNoCase(lTypes,aObjectChildren[j].XmlName)
			  AND structKeyExists(aObjectChildren[j].XmlAttributes,"fkName")
			  AND aObjectChildren[j].XmlAttributes.fkName IS arguments.fkName>
				<cfset thisFieldIndex = j>
				<cfbreak>
			<cfelseif arguments.name IS NOT "" AND arguments.fkName IS ""
			  AND ListFindNoCase(lTypes,aObjectChildren[j].XmlName)
			  AND aObjectChildren[j].XmlAttributes.name IS arguments.name>
				<cfset thisFieldIndex = j>
				<cfbreak>
			<cfelseif arguments.alias IS NOT ""
			  AND ListFindNoCase(lTypes,aObjectChildren[j].XmlName)
			  AND structKeyExists(aObjectChildren[j].XmlAttributes,"alias")
			  AND aObjectChildren[j].XmlAttributes.alias IS arguments.alias>
				<cfset thisFieldIndex = j>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfreturn thisFieldIndex>
	</cffunction>
	
	<cffunction name="createRelationshipTag" returntype="numeric" output="No" 
				hint="I find or create a single relationship within an object in the XML and return its position.">
		<cfargument name="objectIndex" required="Yes" type="numeric" />
		<cfargument name="name" type="string" required="Yes" />
		<cfargument name="type" type="string" required="Yes" />
		<cfargument name="alias" type="string" required="No" default="" />
		<cfargument name="fkName" type="string" required="No" default="" hint="The name of the foreign key in the database."/>
		<cfargument name="sharedKey" type="string" required="No" default="" hint=""/>
		<cfargument name="label" type="string" required="No" default="#cleanLabelText(arguments.alias)#" />
		
		<cfset var j = 0>
		<cfset var thisRelationshipIndex = getRelationshipPosition(objectIndex=arguments.objectIndex,name=arguments.name,fkName=arguments.fkName)>
		<cfset var aObjectChildren = variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren>
		<cfset var objectChildIndex = 1>
		<cfset var objectChildCount =  ArrayLen(aObjectChildren)>
		
		<!--- If the relationship isn't there add it --->
		<cfif thisRelationshipIndex IS 0>
			<!--- Find the highest position for a relationship of this type --->
			<cfloop from="1" to="#objectChildCount#" index="j">
				<cfif aObjectChildren[j].XmlName IS arguments.type>
					<cfset objectChildIndex = j + 1>
				<cfelseif aObjectChildren[j].XmlName IS "field" AND objectChildIndex IS 0 >
					<cfset objectChildIndex = j>
					<cfbreak>
				</cfif>
			</cfloop>
			
			<!--- New relationships get inserted at a suitable position --->
			<cfset ArrayInsertAt(variables.xScaffoldingConfig.scaffolding.objects.XmlChildren[arguments.objectIndex].XmlChildren,objectChildIndex,XmlElemNew(xScaffoldingConfig,type))>
			<cfset variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[objectChildIndex].XmlAttributes["name"] = arguments.name>
			<cfif arguments.alias IS NOT "">
				<cfset variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[objectChildIndex].XmlAttributes["alias"] = arguments.alias>
			</cfif>
			<cfif arguments.label IS NOT "">
				<cfset variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[objectChildIndex].XmlAttributes["label"] = arguments.label>
			</cfif>
			<cfif arguments.fkName IS NOT "">
				<cfset variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[objectChildIndex].XmlAttributes["fkName"] = arguments.fkName>
			</cfif>
			<cfif arguments.sharedKey IS NOT "">
				<cfset variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[objectChildIndex].XmlAttributes["sharedKey"] = arguments.sharedKey>
			</cfif>
			<cfset thisRelationshipIndex = objectChildIndex>
		</cfif>
		
		<cfreturn thisRelationshipIndex>
	</cffunction>
	
	<cffunction name="getRelateOrLinkPosition" returntype="numeric" output="No" 
				hint="I look up the relate or link tag by its from and to values and return its position within the object, if not found return zero.">
		<cfargument name="objectIndex" type="numeric" required="Yes" />
		<cfargument name="relationshipIndex" type="numeric" required="Yes" />
		<cfargument name="from" type="string" required="Yes" />
		<cfargument name="to" type="string" required="Yes" />
		<cfargument name="lTypes" type="string" required="No" default="relate,link" hint="List of the types of tag to search for. Default is all." />
		
		<cfset var aObjectChildren = variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[arguments.relationshipIndex].XmlChildren>
		<cfset var objectChildCount =  ArrayLen(aObjectChildren)>
		<cfset var j = 0>
		<cfset var thisTagIndex = 0>
		
		<!--- Look for the tag in the array --->
		<cfloop from="1" to="#objectChildCount#" index="j">
			<cfif arguments.from IS NOT "" AND arguments.to IS NOT ""
			  AND ListFindNoCase(lTypes,aObjectChildren[j].XmlName)
			  AND aObjectChildren[j].XmlAttributes.from IS arguments.from
			  AND aObjectChildren[j].XmlAttributes.to IS arguments.to>
				<cfset thisTagIndex = j>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfreturn thisTagIndex>
	</cffunction>
	
	<cffunction name="createRelateOrLinkTag" returntype="numeric" output="No" 
				hint="I find or create a single relate or link tag within an object in the XML and return its position.">
		<cfargument name="objectIndex" required="Yes" type="numeric" />
		<cfargument name="relationshipIndex" type="numeric" required="Yes" />
		<cfargument name="from" type="string" required="Yes" />
		<cfargument name="to" type="string" required="Yes" />
		<cfargument name="type" type="string" required="Yes" />
		
		<cfset var j = 0>
		<cfset var thisTagIndex = getRelateOrLinkPosition(objectIndex=arguments.objectIndex,relationshipIndex=arguments.relationshipIndex,from=arguments.from,to=arguments.to,ltypes=arguments.type)>
		<cfset var aObjectChildren = variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[arguments.relationshipIndex].XmlChildren>
		<cfset var objectChildIndex =  ArrayLen(aObjectChildren)>
		
		<!--- If the tag isn't there add it --->
		<cfif thisTagIndex IS 0>
			<cfset objectChildIndex = objectChildIndex + 1>
			<!--- New tags get inserted at the end --->
			<cfset ArrayAppend(variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[arguments.relationshipIndex].XmlChildren,XmlElemNew(xScaffoldingConfig,type))>
			<cfset variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[arguments.relationshipIndex].XmlChildren[objectChildIndex].XmlAttributes["from"] = arguments.from>
			<cfset variables.xScaffoldingConfig.scaffolding.objects.object[arguments.objectIndex].XmlChildren[arguments.relationshipIndex].XmlChildren[objectChildIndex].XmlAttributes["to"] = arguments.to>
			<cfset thisTagIndex = objectChildIndex>
		</cfif>
		
		<cfreturn thisTagIndex>
	</cffunction>
	
	<cffunction name="updateAllParentRelationshipsFromQuery" returntype="void" output="No" 
				hint="I find or create the parent relationships within an object in the XML from a query.">
		<cfargument name="tableName" required="Yes" type="string" hint="Name of the table.">
		<cfargument name="qRelationshipData" required="Yes" type="query" hint="A Query containing the data for each relationship.">
		
		<!--- Find the object tag position --->
		<cfset var objectIndex = getObjectPosition(name=arguments.tableName)>
		<cfset var manyToOneIndex = 0>
		<cfset var relateIndex = 0>
		<cfset var fieldIndex = 0>
		<cfset var stProperties = structNew()>
		<cfset var parentIndex = 0>
		<cfset var thisField = 0>
		
		<!--- Find the manyToOne tag position or create a new one and its associated relate tags --->
		<cfloop query="arguments.qRelationshipData">
			<cfset manyToOneIndex = createRelationshipTag(objectIndex=objectIndex,name=arguments.qRelationshipData.pktable_name,fkname=arguments.qRelationshipData.fk_name,type="manyToOne")>
			<cfset relateIndex = createRelateOrLinkTag(objectIndex=objectIndex,relationshipIndex=manyToOneIndex,from=arguments.qRelationshipData.fkColumn_Name,to=arguments.qRelationshipData.pkColumn_Name,type="relate")>
		
			<!--- Find the foreign key field and add the parent and display attributes --->
			<cfset fieldIndex = getFieldPosition(objectIndex=objectIndex,name=arguments.qRelationshipData.fkColumn_Name)>
			
			<!--- Set up a pointer to the structure containing the attributes of the field tag --->
			<cfset stProperties = variables.xScaffoldingConfig.scaffolding.objects.object[objectIndex].XmlChildren[FieldIndex].XmlAttributes >	
			<!--- Add the parent attribute --->
			<cfset setAttributeValue(stProperties,"parent",arguments.qRelationshipData.pktable_name) >
			
			<!--- find the parent object in the XML --->
			<cfset parentIndex = getObjectPosition(name=arguments.qRelationshipData.pktable_name)>
			<!--- loop over the fields to find the first string column to display in a dropdown list --->
			<cfloop from="1" to="#ArrayLen(variables.xScaffoldingConfig.scaffolding.objects.object[parentIndex].XmlChildren)#" index="thisField">
				<cfif variables.xScaffoldingConfig.scaffolding.objects.object[parentIndex].XmlChildren[thisField].XmlName IS "field"
					AND variables.xScaffoldingConfig.scaffolding.objects.object[parentIndex].XmlChildren[thisField].XmlAttributes.type IS "string">
					<cfset setAttributeValue(stProperties,"display",variables.xScaffoldingConfig.scaffolding.objects.object[parentIndex].XmlChildren[thisField].XmlAttributes.alias) >
					<cfbreak>
				</cfif>
			</cfloop>
			<!--- In case we didn't find a suitable string --->
			<cfset setAttributeValue(stProperties,"display",arguments.qRelationshipData.pkColumn_Name) >
		</cfloop>
		
	</cffunction>
	
	<!--- *** Get and set the current table *** --->
	<cffunction name="setSelectedTable" returntype="void" output="No" >
		<cfargument name="selectedTable" type="string" required="Yes" />
		<cfset variables.selectedTable = arguments.selectedTable>
	</cffunction>
	<cffunction name="getSelectedTable" returntype="string">
		<cfreturn variables.selectedTable>
	</cffunction>
	
	<cffunction name="getSelectedTableAlias" returntype="string" output="No" >
		<cfset var xTable = XmlSearch(variables.xScaffoldingConfig,"/scaffolding/objects/object[@name='#variables.selectedTable#']")>
		<cfif structKeyExists(xTable[1].xmlAttributes,"alias")>
			<cfreturn xTable[1].xmlAttributes["alias"]>
		<cfelse>
			<cfreturn xTable[1].xmlAttributes["name"]>
		</cfif>
	</cffunction>
	
	<cffunction name="getSelectedTableLabel" returntype="string" output="No" >
		<cfset var xTable = XmlSearch(variables.xScaffoldingConfig,"/scaffolding/objects/object[@name='#variables.selectedTable#']")>
		<cfif structKeyExists(xTable[1].xmlAttributes,"label")>
			<cfreturn xTable[1].xmlAttributes["label"]>
		<cfelse>
			<cfreturn cleanLabelText(xTable[1].xmlAttributes["name"])>
		</cfif>
	</cffunction>
	
	<!--- *** Get and set the list of tables to generate code for *** --->
	<cffunction name="setLTables" returntype="void" output="No" >
		<cfargument name="lTables" type="string" required="Yes" />
		<cfset variables.lTables = arguments.lTables>
	</cffunction>
	<cffunction name="getLTables" returntype="string">
		<cfreturn variables.lTables>
	</cffunction>
	
	<cffunction name="getLTableAliases" returntype="string" output="No" >
		<cfset var xTable = "">
		<cfset var lTableAliases = "">
		
		<cfloop list="#variables.lTables#" index="thisTable">
			<cfset xTable = XmlSearch(variables.xScaffoldingConfig,"/scaffolding/objects/object[@name='#thisTable#']")>
			<cfif structKeyExists(xTable[1].xmlAttributes,"alias")>
				<cfset lTableAliases = listAppend(lTableAliases,xTable[1].xmlAttributes["alias"])>
			<cfelse>
				<cfset lTableAliases = listAppend(lTableAliases,xTable[1].xmlAttributes["name"])>
			</cfif>
		</cfloop>
		<cfreturn lTableAliases>
	</cffunction>

<!--- 																									 --->
<!--- *** The following functions convert the XML data into array formats for easier code generation *** --->
<!--- 																									 --->
	
	<cffunction name="getTablesFromXML" returntype="array" output="No"  
				hint="I return an array containing the names of the tables from the XML Configuration.">
		<cfset var i = 0>
		<cfset var aTables = ArrayNew(1)>
		<cfset var xTables = XmlSearch(variables.xScaffoldingConfig,"/scaffolding/objects/object")>
		
		<cfloop index="i" from="1" to="#arrayLen(xTables)#">
			<cfset arrayAppend(aTables,xTables[i].XmlAttributes.name)>
		</cfloop>
		
		<cfreturn aTables>
	</cffunction>
	
	<cffunction name="getFieldsFromXML" returntype="array" output="No" 
				hint="I return an array containing the fields of the selected table from the XML Configuration.">
		<cfargument name="table" type="string" required="Yes" hint="I am the name of the table who's fields are to be output.">
		<cfset var i = 0>
		<cfset var aFields = ArrayNew(1)>
		<cfset var quotedTable = "'#arguments.table#'">
		<cfset var xFields = XmlSearch(variables.xScaffoldingConfig,"/scaffolding/objects/object[@name=#quotedTable#]/field")>
		
		<cfloop index="i" from="1" to="#arrayLen(xFields)#">
			<cfset arrayAppend(aFields,xFields[i].XmlAttributes)>
			<cfset aFields[i]["table"] = arguments.table>
			<!--- Set default values on missing entries in the XML --->
			<cfif NOT structKeyExists(aFields[i],"alias")>
				<cfset aFields[i]["alias"] = aFields[i]["name"]>
			</cfif>
			<cfif NOT structKeyExists(aFields[i],"label")>
				<cfset aFields[i]["label"] = cleanLabelText(aFields[i]["alias"])>
			</cfif>
			<cfif NOT structKeyExists(aFields[i],"showOnList")>
				<cfset aFields[i]["showOnList"] = "true">
			</cfif>
			<cfif NOT structKeyExists(aFields[i],"showOnForm")>
				<cfset aFields[i]["showOnForm"] = "true">
			</cfif>
			<cfif NOT structKeyExists(aFields[i],"type")>
				<cfset aFields[i]["type"] = "string">
			</cfif>
			<cfif NOT structKeyExists(aFields[i],"formType")>
				<cfif structKeyExists(aFields[i],"parent")>
					<cfset aFields[i]["formType"] = "Dropdown">
				<cfelseif aFields[i].type IS "date">
					<cfset aFields[i]["formType"] = "Calendar">
				<cfelseif aFields[i].type IS "boolean">
					<cfset aFields[i]["formType"] = "Checkbox">
				<cfelseif structKeyExists(aFields[i],"maxlength") AND aFields[i]["maxlength"] GT 200>
					<cfset aFields[i]["formType"] = "TextArea">
				<cfelse>
					<cfset aFields[i]["formType"] = "Text">
				</cfif>
			</cfif>
			
			<cfif NOT structKeyExists(aFields[i],"format")>
				<cfif aFields[i].type IS "date">
					<cfset aFields[i]["format"] = "Date(dd/mmm/yyyy)">
				<cfelseif aFields[i].type IS "boolean">
					<cfset aFields[i]["format"] = "YesNo">
				<cfelseif aFields[i].type IS "money">
					<cfset aFields[i]["format"] = "Currency">
				<cfelseif aFields[i].type IS "integer">
					<cfset aFields[i]["format"] = "Number(9)">
				<cfelseif aFields[i].type IS "float">
					<cfset aFields[i]["format"] = "Number(9.99)">
				<cfelse>
					<cfset aFields[i]["format"] = "Trim">
				</cfif>
			</cfif>
			
			<cfif NOT structKeyExists(aFields[i],"size")>
				<cfif aFields[i].formType IS "Dropdown">
					<cfset aFields[i]["size"] = "1">
				<cfelseif aFields[i].formType IS "TextArea">
					<cfset aFields[i]["size"] = "30x4">
				<cfelseif aFields[i].formType IS "Text">
					<cfif aFields[i].type IS "integer" OR aFields[i].type IS "float">
						<cfset aFields[i]["size"] = "15">
					<cfelse>
						<cfset aFields[i]["size"] = "30">
					</cfif>
				<cfelse>
					<cfset aFields[i]["size"] = "0">
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn aFields>
	</cffunction>
	
	<cffunction name="getFieldListFromXML" returntype="string" output="No" 
				hint="I return a list of field aliases for a table." >
		<cfargument name="table" type="string" required="Yes" hint="I am the name of the table who's fields are to be output.">
		<cfset var i = 0>
		<cfset var aFields = getFieldsFromXML(arguments.table)>
		<cfset var lFields = "">
		
		<cfloop from="1" to="#arrayLen(aFields)#" index="i">
			<cfif structKeyExists(aFields[i],"alias")>
				<cfset lFields = ListAppend(lFields,aFields[i].alias)>
			<cfelse>
				<cfset lFields = ListAppend(lFields,aFields[i].name)>
			</cfif>
		</cfloop>
		
		<cfreturn lFields>
	</cffunction>
	
	<cffunction name="getPKFieldsFromXML" returntype="array" output="No" 
				hint="I return an array of the primary key fields for a table." >
		<cfargument name="table" type="string" required="Yes" hint="I am the name of the table who's PK fields are to be output.">
		<cfset var i = 0>
		<cfset var aFields = getFieldsFromXML(arguments.table)>
		<cfset var aPKFields = ArrayNew(1)>
		<cfset var len = arrayLen(aFields)>
		<!--- Loop over the array of fields and find the Primary Keys --->
		<cfloop from="1" to="#len#" index="i">
			<cfif structKeyExists(aFields[i],"primaryKeySeq") AND aFields[i].primaryKeySeq GT 0>
				<cfset aPKFields[aFields[i].primaryKeySeq] = aFields[i]>
			</cfif>
		</cfloop>
		
		<cfreturn aPKFields>
	</cffunction>
	
	<cffunction name="getPKListFromXML" returntype="string" output="No" 
				hint="I return a list of prinary key field aliases for a table." >
		<cfargument name="table" type="string" required="Yes" hint="I am the name of the table who's PK fields are to be output.">
		<cfset var lPKFields = "">
		<cfset var i = 0>
		<cfset var aPKFields = getPKFieldsFromXML(arguments.table)>
			
		<cfloop from="1" to="#ArrayLen(aPKFields)#" index="i">
			<cfset lPKFields = ListAppend(lPKFields,aPKFields[i].alias)>
		</cfloop>
		
		<cfreturn lPKFields>
	</cffunction>
	
	<cffunction name="getJoinedFieldListFromXML" returntype="string" output="No" 
				hint="I return a list of field aliases for the fields of joined tables to a table.">
		<cfargument name="table" type="string" required="Yes" hint="I am the name of the table who's joined tables fields are to be output.">
		<cfargument name="type" type="string" required="No" default="" hint="I select the type of field to be displayed, can be List or Form.">
		<cfset var i = 0>
		<cfset var aFields = getJoinedFieldsFromXML(arguments.table)>
		<cfset var lFields = "">
		
		<cfif arguments.type IS "List">
			<cfloop from="1" to="#arrayLen(aFields)#" index="i">
				<cfif structKeyExists(aFields[i],"showOnList") AND aFields[i].showOnList>
					<cfset lFields = ListAppend(lFields,aFields[i].alias)>
				</cfif>
			</cfloop>
		<cfelseif arguments.type IS "Form">
			<cfloop from="1" to="#arrayLen(aFields)#" index="i">
				<cfif structKeyExists(aFields[i],"showOnForm") AND aFields[i].showOnForm>
					<cfset lFields = ListAppend(lFields,aFields[i].alias)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfloop from="1" to="#arrayLen(aFields)#" index="i">
				<cfset lFields = ListAppend(lFields,aFields[i].alias)>
			</cfloop>
		</cfif>
		
		<cfreturn lFields>
	</cffunction>
	
	<cffunction name="getJoinedFieldsFromXML" returntype="array" output="No" 
				hint="I return a array of fields from the joined tables to a table.">
		<cfargument name="table" type="string" required="Yes" hint="I am the name of the table who's joined tables fields are to be output.">
		<cfset var i = 0>
		<cfset var aFields = getFieldsFromXML(arguments.table)>
		<cfset var aJoinedFields = arrayNew(1)>
		
		<cfloop from="1" to="#arrayLen(aFields)#" index="i">
			<cfif structKeyExists(aFields[i],"parent")>
				<cfset aJoinedFields = ArrayConcat(aJoinedFields,getFieldsFromXML(aFields[i].parent))>
			</cfif>
		</cfloop>
		
		<cfreturn aJoinedFields>
	</cffunction>
	
	<cffunction name="getRelationshipsFromXML" returntype="array" output="No" 
				hint="I return a array containing the tables related to the selected table from the XML Configuration.">
		<cfargument name="table" required="Yes" hint="I am the name of the table who's realtionships are to be output.">
		<cfargument name="type" required="Yes" hint="I am the type of relationship required">
		<cfset var i = 0>
		<cfset var j = 0>
		<cfset var aRelationships = ArrayNew(1)>
		<cfset var quotedTable = "'#arguments.table#'">
		<cfset var stData = 0>
		<cfset var xRelationships = XmlSearch(variables.xScaffoldingConfig,"/scaffolding/objects/object[@name=#quotedTable#]/#arguments.type#")>
		
		<cfloop index="i" from="1" to="#arrayLen(xRelationships)#">
			<cfset stData = structNew()>
			<cfset stData["Name"] = xRelationships[i].XmlAttributes.name>
			<cfif structKeyExists(xRelationships[i].XmlAttributes,"alias")>
				<cfset stData["Alias"] = xRelationships[i].XmlAttributes.alias>
			<cfelse>
				<cfset stData["Alias"] = xRelationships[i].XmlAttributes.name>
			</cfif>
			<cfset stData["Links"] = arrayNew(1)>
			<cfloop index="j" from="1" to="#arrayLen(xRelationships[i].XmlChildren)#">
				<cfset stData.Links[j] = xRelationships[i].XmlChildren[j].XmlAttributes>
				<cfset stData.Links[j]["type"] = xRelationships[i].XmlChildren[j].XmlName>
			</cfloop>
			
			<cfset arrayAppend(aRelationships,stData)>
		</cfloop>
		
		<cfreturn aRelationships>
	</cffunction>
	
	<cffunction name="getDottedPath" returntype="string" output="no" 
				hint="I return the Path to the model.">
		<cfargument name="destinationPath" required="Yes" hint="I am the path to the object.">
		<cfargument name="datasource" required="Yes" hint="I am the datasource name.">
		<cfargument name="objectName" required="Yes" hint="I am the name of the object.">
		
		<cfset var destPath = replace(getDirectoryFromPath(arguments.destinationPath),"#variables.OSdelimiter#",".","all")>
		<cfset var pathInfo = replace(getDirectoryFromPath(cgi.PATH_INFO),"/",".","all") >
		<cfset var dottedPath = "" >
		
		<cfif arguments.datasource IS "">
			<cfset dottedPath = RemoveChars(destPath,1,FindNoCase(pathInfo,destPath,1)) & arguments.objectName >
		<cfelse>
			<cfset dottedPath = RemoveChars(destPath,1,FindNoCase(pathInfo,destPath,1)) & "model.m#arguments.datasource#." & arguments.objectName >
		</cfif>
		<cfreturn trim(dottedPath)>
	</cffunction>
	
	<cffunction name="GetOSdelimiter" returntype="string" output="No">
		<cfreturn variables.OSdelimiter>
	</cffunction>
	
</cfcomponent>