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
<<!--- Get an array of fields --->>
<<cfset aFields = oMetaData.getFieldsFromXML(objectName)>>
<<!--- Get an array of joinedfields --->>
<<cfset aJoinedFields = oMetaData.getJoinedFieldsFromXML(objectName)>>
<<cfset lFields = "">>

<<cfoutput>>

	<cffunction name="setMemento" access="public" returntype="$$objectName$$" output="false">
		<cfargument name="memento" type="struct" required="yes"/>
		<cfset variables.instance = arguments.memento />
		<cfreturn this />
	</cffunction>
	<cffunction name="getMemento" access="public" returntype="struct" output="false" >
		<cfreturn variables.instance />
	</cffunction>
	
	<!--- Fields from the table --->
<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">><<cfset lFields = ListAppend(lFields, aFields[i].alias)>>
	<cffunction name="set$$aFields[i].alias$$" access="public" returntype="void" output="false">
		<cfargument name="$$aFields[i].alias$$" type="any" required="true" />
		<cfset variables.instance.$$aFields[i].alias$$ = arguments.$$aFields[i].alias$$ />
	</cffunction>
	<cffunction name="get$$aFields[i].alias$$" access="public" returntype="any" output="false">
		<cfreturn variables.instance.$$aFields[i].alias$$ />
	</cffunction>
<</cfloop>>

	<!--- Fields from joined tables --->
<<cfloop from="1" to="$$ArrayLen(aJoinedFields)$$" index="i">><<!--- Only add them if they have a unique name --->><<cfif ListFindNoCase(lFields,aJoinedFields[i].alias) EQ 0>><<cfset lFields = ListAppend(lFields, aJoinedFields[i].alias)>>
	<cffunction name="set$$aJoinedFields[i].alias$$" access="package" returntype="void" output="false">
		<cfargument name="$$aJoinedFields[i].alias$$" type="any" required="true" />
		<cfset variables.instance.$$aJoinedFields[i].alias$$ = arguments.$$aJoinedFields[i].alias$$ />
	</cffunction>
	<cffunction name="get$$aJoinedFields[i].alias$$" access="public" returntype="any" output="false">
		<cfreturn variables.instance.$$aJoinedFields[i].alias$$ />
	</cffunction><</cfif>>
<</cfloop>>

	<cffunction name="dump" access="public" output="true" return="void">
		<cfargument name="abort" type="boolean" default="false" />
		<cfdump var="#variables.instance#" />
		<cfif arguments.abort>
			<cfabort />
		</cfif>
	</cffunction>
	
<</cfoutput>>
