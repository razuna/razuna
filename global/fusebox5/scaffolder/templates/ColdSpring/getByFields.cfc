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

	<cffunction name="getByFields" access="public" output="false" returntype="query">
		<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
		<cfargument name="$$aFields[i].alias$$" type="$$aFields[i].type$$" required="false" /><</cfloop>>
		<<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">><<cfif NOT listFindNoCase(lFields,aJoinedFields[i].alias)>>
		<cfargument name="$$aJoinedFields[i].alias$$" type="$$aJoinedFields[i].type$$" required="false" /><</cfif>><</cfloop>>
		
		<cfargument name="sortByFieldList" required="No" type="string">
		<cfargument name="startrow" type="numeric" required="No" default="1" />
		<cfargument name="maxrows" type="numeric" required="No" />
		
		<cfset var qList = "" />
		<cfset var orderBy = "" />
		<cfset var thisOrder = "" />
		
		<!--- Query the table. ---><<cfif ArrayLen(aJoinedObjects)>>
		<!--- Join all the associated parent tables (uses a left outer join for safety). ---><</cfif>>
		<cfquery name="qList" datasource="#variables.dsn#">
			SELECT 	<cfif structKeyExists(arguments,"maxrows") AND arguments.maxrows GT 0>TOP #arguments.maxrows#</cfif>
					<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>$$tableName$$.$$aFields[i].name$$ AS $$aFields[i].alias$$<<cfif i NEQ ArrayLen(aFields) OR ArrayLen(aJoinedFields) GT 0 >>,$$chr(10)$$<</cfif>>
					<</cfloop>>
					<<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">>
 					$$aJoinedFields[i].table$$.$$aJoinedFields[i].name$$ AS $$aJoinedFields[i].alias$$<<cfif i NEQ ArrayLen(aJoinedFields)>>,$$chr(10)$$<</cfif>>
					<</cfloop>>
			FROM	$$tableName$$<<cfloop from="1" to="$$ArrayLen(aJoinedObjects)$$" index="i">>
			LEFT OUTER JOIN $$aJoinedObjects[i].name$$ ON 
			<<cfloop from="1" to="$$ArrayLen(aJoinedObjects[i].links)$$" index="j">>$$objectName$$.$$aJoinedObjects[i].links[j].from$$ = $$aJoinedObjects[i].name$$.$$aJoinedObjects[i].links[j].to$$<<cfif j NEQ ArrayLen(aJoinedObjects[i].links)>> AND <</cfif>><</cfloop>>
			<</cfloop>>
			WHERE	0=0
		<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
			<cfif structKeyExists(arguments,"$$aFields[i].alias$$") and len(arguments.$$aFields[i].alias$$)>
				AND	$$tableName$$.$$aFields[i].name$$ = <cfqueryparam value="#arguments.$$aFields[i].alias$$#" CFSQLType="$$aFields[i].SQLType$$" />
			</cfif><</cfloop>>
		<<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">>
			<cfif structKeyExists(arguments,"$$aJoinedFields[i].alias$$") and len(arguments.$$aJoinedFields[i].alias$$)>
				AND	$$aJoinedFields[i].table$$.$$aJoinedFields[i].name$$ = <cfqueryparam value="#arguments.$$aJoinedFields[i].alias$$#" CFSQLType="$$aJoinedFields[i].SQLType$$" />
			</cfif><</cfloop>>
			<cfif startrow IS NOT 1>
				AND $$lPKFields$$ NOT IN(SELECT TOP #val(startrow - 1)# $$lPKFields$$ FROM $$tableName$$ WHERE 0=0
				<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
					<cfif structKeyExists(arguments,"$$aFields[i].alias$$") and len(arguments.$$aFields[i].alias$$)>
						AND	$$tableName$$.$$aFields[i].name$$ = <cfqueryparam value="#arguments.$$aFields[i].alias$$#" CFSQLType="$$aFields[i].SQLType$$" />
					</cfif><</cfloop>>
				<<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">>
					<cfif structKeyExists(arguments,"$$aJoinedFields[i].alias$$") and len(arguments.$$aJoinedFields[i].alias$$)>
						AND	$$aJoinedFields[i].table$$.$$aJoinedFields[i].name$$ = <cfqueryparam value="#arguments.$$aJoinedFields[i].alias$$#" CFSQLType="$$aJoinedFields[i].SQLType$$" />
					</cfif><</cfloop>>
				)
			</cfif>
			<cfif structKeyExists(arguments, "sortByFieldList") and len(arguments.sortByFieldList)>
				<cfset orderBy = "">
				<cfloop list="#arguments.sortByFieldList#" index="thisOrder">
					<cfif ListGetAt(thisOrder,3,"|") IS "ASC">
						<cfset orderBy = ListAppend(orderBy,"#ListGetAt(thisOrder,1,'|')#.#ListGetAt(thisOrder,2,'|')# ASC") />
					<cfelse>
						<cfset orderBy = ListAppend(orderBy,"#ListGetAt(thisOrder,1,'|')#.#ListGetAt(thisOrder,2,'|')# DESC") />
					</cfif>
				</cfloop>
				
				ORDER BY #orderBy#
			</cfif>
		</cfquery>
		
		<cfreturn qList />
	</cffunction>
	
<</cfoutput>>

