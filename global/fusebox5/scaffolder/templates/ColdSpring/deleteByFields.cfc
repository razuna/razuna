<<!---
Copyright 2007 Objective Internet Ltd - http://www.objectiveinternet.com

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
<<!--- Generate a list of the table fields --->>
<<cfset lFields = oMetaData.getFieldListFromXML(objectName)>>
<<!--- Generate a list of the Primary Key fields --->>
<<cfset lPKFields = oMetaData.getPKListFromXML(objectName)>>
<<!--- Get an array of fields --->>
<<cfset aFields = oMetaData.getFieldsFromXML(objectName)>>
<<!--- Get an array of PK fields --->>
<<cfset aPKFields = oMetaData.getPKFieldsFromXML(objectName)>>
<<!--- Get an array of joinedfields --->>
<<cfset aJoinedFields = oMetaData.getJoinedFieldsFromXML(objectName)>>
<<cfoutput>>
	
	<cffunction name="deleteByFields" access="public" output="false" returntype="query">
		<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
		<cfargument name="$$aFields[i].alias$$" type="$$aFields[i].type$$" required="false" /><</cfloop>>
		
		<cfset var qList = "" />
	
		<cftry>
			<cfquery name="qList" datasource="#variables.dsn#">
				DELETE $$objectName$$
				WHERE	0=0
			<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
				<cfif structKeyExists(arguments,"$$aFields[i].alias$$") and len(arguments.$$aFields[i].alias$$)>
					AND	$$aFields[i].name$$ = <cfqueryparam value="#arguments.$$aFields[i].alias$$#" CFSQLType="$$aFields[i].SQLType$$" />
				</cfif><</cfloop>>
			</cfquery>
			<cfcatch type="database">
				<cfreturn false />
			</cfcatch>
		</cftry>
		<cfreturn true />
	</cffunction>
	
<</cfoutput>>

