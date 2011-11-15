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
<<cfoutput>>
	<cffunction name="getAllWithJoin" output="false" returntype="query" hint="I get ALL the records, with an outer join to any parent tables.">
		<cfargument name="sortByFieldList" default="" type="string" required="No" Hint="I am a list of attributes by which to sort the result, In the format table|column|ASC/DESC,table|column|ASC/DESC...">
		<cfset var Query = createQuery() />
		<cfset var Order = Query.getOrder() />
		<cfset var thisOrder = "" />
	<<cfif ArrayLen(aJoinedObjects)>>
		<!--- Left join all the associated tables (uses a left join for safety). --->
		<!--- Syntax is: Query.leftJoin(joinFromObjectAlias,joinToObjectAlias,relationshipAlias) ---><</cfif>>
	<<cfloop from="1" to="$$ArrayLen(aJoinedObjects)$$" index="i">>
		<cfset Query.leftJoin("$$objectName$$", "$$aJoinedObjects[i].name$$", "$$aJoinedObjects[i].alias$$")/>
	<</cfloop>>
	
		<cfloop list="#arguments.sortByFieldList#" index="thisOrder">
			<cfif ListGetAt(thisOrder,3,"|") IS "ASC">
				<cfset Order.setAsc(ListGetAt(thisOrder,1,"|"),ListGetAt(thisOrder,2,"|")) />
			<cfelse>
				<cfset Order.setDesc(ListGetAt(thisOrder,1,"|"),ListGetAt(thisOrder,2,"|")) />
			</cfif>
		</cfloop>
		
		<!--- Return the query --->
		<cfreturn getByQuery(Query) />
	</cffunction>
<</cfoutput>>
