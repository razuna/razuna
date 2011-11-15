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
<<!--- Create a list of the many to one joined objects --->>
<<cfset aJoinedObjects = oMetaData.getRelationshipsFromXML(objectName,"manyToOne")>>
<<!--- Get the primary key fields for the object --->>
<<cfset lPrimaryKeys = oMetaData.getPKListFromXML(objectName)>>
<<cfoutput>>
	<cffunction name="getNWithJoin" output="false" returntype="query" hint="I get the selected N records, with an outer join to any parent tables.">
		<cfargument name="sortByFieldList" default="" type="string" required="No" Hint="I am a list of attributes by which to sort the result, In the format table|column|ASC/DESC,table|column|ASC/DESC..."/>
		<cfargument name="startrow" default="1" type="numeric" required="No" />
		<cfargument name="maxrows" default="0" type="numeric" required="No" />
		<cfset var QuerySkip = createQuery() />
		<cfset var OrderSkip = QuerySkip.getOrder() />
		<cfset var QueryRecordset = createQuery() />
		<cfset var OrderRecordset = QueryRecordset.getOrder() />
		<cfset var where = QueryRecordset.getWhere() />
		<cfset var qSkip = ""/>
		<cfset var thisOrder = "" />
		
		<cfif arguments.startrow GT 1>
			<!--- Set up the sort order for the skipped records --->
			<cfloop list="#arguments.sortByFieldList#" index="thisOrder">
				<cfif ListGetAt(thisOrder,3,"|") IS "ASC">
					<cfset OrderSkip.setAsc(ListGetAt(thisOrder,1,"|"),ListGetAt(thisOrder,2,"|")) />
				<cfelse>
					<cfset OrderSkip.setDesc(ListGetAt(thisOrder,1,"|"),ListGetAt(thisOrder,2,"|")) />
				</cfif>
			</cfloop>
			<!--- Get the Primary Keys of the records we want to skip --->
			<cfset QuerySkip.returnObjectFields("$$objectName$$","$$lPrimaryKeys$$") />
			<cfset QuerySkip.setMaxrows(arguments.startrow - 1) />
			<cfset qSkip = getByQuery(QuerySkip) />
			<cfset where.isNotIn("$$objectName$$","$$lPrimaryKeys$$",valuelist(qSkip.$$lPrimaryKeys$$)) />
		</cfif>
	  <<cfif ArrayLen(aJoinedObjects)>>
		<!--- Left join all the associated tables (uses a left join for safety). --->
		<!--- Syntax is: Query.leftJoin(joinFromObjectAlias,joinToObjectAlias,relationshipAlias) ---><</cfif>>
	  <<cfloop from="1" to="$$ArrayLen(aJoinedObjects)$$" index="i">>
		<cfset QueryRecordset.leftJoin("$$objectName$$", "$$aJoinedObjects[i].name$$", "$$aJoinedObjects[i].alias$$")/>
	  <</cfloop>>
		
		<!--- Set up the sort order for the required records --->
		<cfloop list="#arguments.sortByFieldList#" index="thisOrder">
			<cfif ListGetAt(thisOrder,3,"|") IS "ASC">
				<cfset OrderRecordset.setAsc(ListGetAt(thisOrder,1,"|"),ListGetAt(thisOrder,2,"|")) />
			<cfelse>
				<cfset OrderRecordset.setDesc(ListGetAt(thisOrder,1,"|"),ListGetAt(thisOrder,2,"|")) />
			</cfif>
		</cfloop>
		<cfif arguments.maxrows GT 0>
			<cfset QueryRecordset.setMaxrows(arguments.maxrows) />
		</cfif>
		
		<!--- Return the query --->
		<cfreturn getByQuery(QueryRecordset) />
	</cffunction>
<</cfoutput>>