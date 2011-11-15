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
<<!--- Get the first primary key field for the object to use as name of count. --->>
<<cfset FieldName = ListFirst(oMetaData.getPKListFromXML(objectName))>>
<<cfoutput>>
	<cffunction name="getRecordCount" output="false" returntype="numeric" hint="I get the number of records in the table.">
		<cfset var QueryCount = createQuery() />
		<cfset var qCount = ""/>
		
		<!--- Get the recordcount for the table --->
		<!--- There is a bug in Reactor which requires that the count field must be named the same as a real field in the table. --->
		<cfset QueryCount.returnObjectFields("$$objectName$$","$$FieldName$$") />
		<cfset QueryCount.setFieldExpression("$$objectName$$","$$FieldName$$","COUNT(*)","CF_SQL_INTEGER") />
		<cfset qCount = getByQuery(QueryCount) />
		
		<!--- Return the recordcount --->
		<cfreturn qCount.$$FieldName$$ />
	</cffunction>
<</cfoutput>>