<<!---
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
--->>
<<!--- Set the name of the object (table) being updated --->>
<<cfset objectName = oMetaData.getSelectedTableAlias()>>
<<cfoutput>>
	<fuseaction name="Initialise" access="internal">
		<!-- Initialise: I Initialise all of the required gateway objects. -->
		<!-- Create the reactorFactory -->
		<reactor:initialize configuration="#expandPath('Reactor.xml')#"/>
		<!-- Create a Gateway object for each table in the database. -->
		<<cfloop list="$$oMetaData.getLTableAliases()$$" index="objectName" >>
		<reactor:gateway alias="$$objectName$$" returnvariable="Application.ao__AppObj_m$$dbName$$_$$objectName$$_Gateway" /><</cfloop>>
	</fuseaction>
<</cfoutput>>
	
