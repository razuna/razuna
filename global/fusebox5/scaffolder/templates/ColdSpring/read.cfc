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
<<!--- Set the name of the object (table alias) being updated --->>
<<cfset objectName = oMetaData.getSelectedTableAlias()>>
<<!--- Set the name of the table being updated --->>
<<cfset tableName = oMetaData.getSelectedTable()>>
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
<<!--- Create a array of the many to one joined objects --->>
<<cfset aJoinedObjects = oMetaData.getRelationshipsFromXML(objectName,"manyToOne")>>

<<cfoutput>>

	<cffunction name="read" access="public" output="false" returntype="void">
		<cfargument name="$$objectName$$" type="$$objectName$$Record" required="true" />

		<cfset var qRead = "" />
		<cfset var strReturn = structNew() />
		<cftry>
			<cfquery name="qRead" datasource="#variables.dsn#">
				SELECT	<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>$$tableName$$.$$aFields[i].name$$ AS $$aFields[i].alias$$<<cfif i NEQ ArrayLen(aFields) OR ArrayLen(aJoinedFields) GT 0 >>,$$chr(10)$$<</cfif>>
						<</cfloop>>
						<<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">>
	 					$$aJoinedFields[i].table$$.$$aJoinedFields[i].name$$ AS $$aJoinedFields[i].alias$$<<cfif i NEQ ArrayLen(aJoinedFields)>>,$$chr(10)$$<</cfif>>
						<</cfloop>>
				FROM	$$tableName$$<<cfloop from="1" to="$$ArrayLen(aJoinedObjects)$$" index="i">>
				LEFT OUTER JOIN $$aJoinedObjects[i].name$$ ON 
				<<cfloop from="1" to="$$ArrayLen(aJoinedObjects[i].links)$$" index="j">>$$objectName$$.$$aJoinedObjects[i].links[j].from$$ = $$aJoinedObjects[i].name$$.$$aJoinedObjects[i].links[j].to$$<<cfif j NEQ ArrayLen(aJoinedObjects[i].links)>> AND <</cfif>><</cfloop>>
				<</cfloop>>
				WHERE		0=0
				<<cfloop from="1" to="$$ArrayLen(aPKFields)$$" index="i">>
			AND		$$tableName$$.$$aPKFields[i].name$$ = <cfqueryparam value="#arguments.$$objectName$$.get$$aPKFields[i].alias$$()#" CFSQLType="$$aPKFields[i].SQLtype$$" /><</cfloop>>
			</cfquery>
			<cfcatch type="database">
				<!--- Somthing went wrong create so we an empty query --->
				<cfset qRead = queryNew("<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>$$aFields[i].alias$$,<</cfloop>><<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">>$$aJoinedFields[i].alias$$,<</cfloop>>") />
			</cfcatch>
		</cftry>
		<cfif qRead.recordCount>
			<cfset strReturn = queryRowToStruct(qRead)>
			<cfset arguments.$$objectName$$.init(argumentCollection=strReturn)>
		</cfif>
	</cffunction>
	
<</cfoutput>>

