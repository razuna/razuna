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
	
	<cffunction name="validate" access="public" returntype="array" output="false">
		<cfset var errors = arrayNew(1) />
		<cfset var thisError = structNew() />
		
<<cfloop from="1" to="$$ArrayLen(aFields)$$" index="i">>
		
		<!--- $$aFields[i].name$$ --->
	<<cfif structKeyExists(aFields[i],"required") AND aFields[i].required>><<!--- Required Field --->>
		<cfif (NOT len(trim(get$$aFields[i].name$$())))>
			<cfset thisError.field = "$$aFields[i].name$$" />
			<cfset thisError.type = "required" />
			<cfset thisError.message = "$$aFields[i].label$$ is required." />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
	<</cfif>>
	<<cfif structKeyExists(aFields[i],"type") AND (aFields[i].type IS "integer" OR aFields[i].type IS "numeric")>><<!--- Numeric --->>
		<cfif (len(trim(get$$aFields[i].name$$())) AND NOT isNumeric(trim(get$$aFields[i].name$$())))>
	<<cfelseif structKeyExists(aFields[i],"type") AND aFields[i].type IS "boolean">><<!--- Boolean --->>
		<cfif (len(trim(get$$aFields[i].name$$())) AND NOT isBoolean(trim(get$$aFields[i].name$$())))>
	<<cfelseif structKeyExists(aFields[i],"type") AND aFields[i].type IS "date">><<!--- Date --->>
		<cfif (len(trim(get$$aFields[i].name$$())) AND NOT LSIsDate(trim(get$$aFields[i].name$$())) AND NOT IsDate(trim(get$$aFields[i].name$$())))>
	<<cfelseif structKeyExists(aFields[i],"type") AND aFields[i].type IS "time">><<!--- Time --->>
		<cfif (len(trim(get$$aFields[i].name$$())) AND NOT LSIsDate(trim(get$$aFields[i].name$$())))>
	<<cfelse>>
		<cfif (len(trim(get$$aFields[i].name$$())) AND NOT IsSimpleValue(trim(get$$aFields[i].name$$())))>
	<</cfif>>
			<cfset thisError.field = "$$aFields[i].name$$" />
			<cfset thisError.type = "invalidType" />
			<cfset thisError.message = "$$aFields[i].label$$ is not $$aFields[i].type$$." />
			<cfset arrayAppend(errors,duplicate(thisError)) />
	<<cfif structKeyExists(aFields[i],"type") AND aFields[i].type IS "date">>	<cfelseif len(trim(get$$aFields[i].name$$())) AND get$$aFields[i].name$$() DOES NOT CONTAIN "{">
			<cfset set$$aFields[i].name$$(Replace(get$$aFields[i].name$$(),"/","-","all"))>
			<cfset set$$aFields[i].name$$(LSParseDateTime(get$$aFields[i].name$$()))>
	<</cfif>>
		</cfif>
	<<cfif structKeyExists(aFields[i],"type") AND structKeyExists(aFields[i],"maxlength") 
	  AND aFields[i].type IS NOT "integer" AND aFields[i].type IS NOT "numeric" 
	  AND aFields[i].type IS NOT "boolean" AND aFields[i].type IS NOT "date" AND aFields[i].type IS NOT "time" 
	  AND aFields[i].size GT 0>>
		<cfif (len(trim(get$$aFields[i].name$$())) GT $$aFields[i].maxlength$$)>
			<cfset thisError.field = "$$aFields[i].name$$" />
			<cfset thisError.type = "tooLong" />
			<cfset thisError.message = "$$aFields[i].label$$ is too long, max is $$aFields[i].maxlength$$." />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>
	<</cfif>>
<</cfloop>>
		
		<cfreturn errors />
	</cffunction>
	
<</cfoutput>>
